package com.fabirt.waterreminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.core.view.WindowCompat
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private lateinit var callbackChannel: MethodChannel
    lateinit var dataStoreProvider: DataStoreProvider

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        createAlarmNotificationChannel()
        dataStoreProvider = DataStoreProvider(this)
        // Eski alarmı kesinlikle iptal et (Sadece Flutter bildirimi kullanacağız)
        cancelWaterAlarm()
    }

    override fun onResume() {
        super.onResume()
        lifecycleScope.launch {
            dataStoreProvider.verifyDailyReset()
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        callbackChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, K.METHOD_CHANNEL_NAME).apply {
            setMethodCallHandler(this@MainActivity)
        }
        
        // Alarm servisi için ayrı channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.fabirt.waterreminder/alarm").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        try {
                            val alarmId = call.argument<Int>("alarmId")!!
                            val triggerTimeMillis = call.argument<Long>("triggerTimeMillis")!!
                            val title = call.argument<String>("title")!!
                            val message = call.argument<String>("message")!!
                            
                            scheduleWaterAlarm(alarmId, triggerTimeMillis, title, message)
                            result.success(true)
                        } catch (e: Exception) {
                            android.util.Log.e("MainActivity", "Alarm zamanlama hatası: ${e.message}")
                            result.error("ALARM_ERROR", e.message, null)
                        }
                    }
                    "cancelAllAlarms" -> {
                        try {
                            cancelAllWaterAlarms()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("CANCEL_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            K.METHOD_DRINK_WATER -> {
                val milliliters = call.arguments as Int
                lifecycleScope.launch {
                    dataStoreProvider.setWaterMilliliters(milliliters)
                }
                result.success(null)
            }
            K.METHOD_CHANGE_NOTIFICATION_ENABLED -> {
                lifecycleScope.launch {
                    val enabled = call.arguments as Boolean
                    dataStoreProvider.setNotificationEnabled(enabled)
                    // Güncellenmiş ayarları Flutter'a bildir
                    val settings = dataStoreProvider.waterSettingsFlow.first()
                    callbackChannel.invokeMethod(K.METHOD_WATER_SETTINGS_CHANGED, settings.asMap())
                }
                result.success(null)
            }
            K.METHOD_SUBSCRIBE_TO_DATA_STORE -> {
                subscribeToDataStore()
                result.success(null)
            }
            K.METHOD_CLEAR_DATA_STORE -> {
                clearDataStore()
                result.success(null)
            }
            K.METHOD_SET_RECOMMENDED_MILLILITERS -> {
                val milliliters = call.arguments as Int
                lifecycleScope.launch {
                    dataStoreProvider.setRecommendedMilliliters(milliliters)
                    // Güncellenmiş ayarları Flutter'a bildir
                    val settings = dataStoreProvider.waterSettingsFlow.first()
                    callbackChannel.invokeMethod(K.METHOD_WATER_SETTINGS_CHANGED, settings.asMap())
                }
                result.success(null)
            }
            K.METHOD_SET_REMINDER_INTERVAL -> {
                val minutes = call.arguments as Int
                lifecycleScope.launch {
                    dataStoreProvider.setReminderIntervalMinutes(minutes)
                    // Alarm kurmuyoruz (Native alarm iptal)
                    cancelWaterAlarm()
                    // Güncellenmiş ayarları Flutter'a bildir
                    val settings = dataStoreProvider.waterSettingsFlow.first()
                    callbackChannel.invokeMethod(K.METHOD_WATER_SETTINGS_CHANGED, settings.asMap())
                }
                result.success(null)
            }
            K.METHOD_RESET_WATER -> {
                lifecycleScope.launch {
                    dataStoreProvider.resetWater()
                    // Güncellenmiş ayarları Flutter'a bildir
                    val settings = dataStoreProvider.waterSettingsFlow.first()
                    callbackChannel.invokeMethod(K.METHOD_WATER_SETTINGS_CHANGED, settings.asMap())
                }
                result.success(null)
            }
            "scheduleNativeNotification" -> {
                try {
                    val triggerTimeMillis = call.argument<Long>("triggerTime")!!
                    val notificationId = call.argument<Int>("notificationId")!!
                    val title = call.argument<String>("title")!!
                    val message = call.argument<String>("message")!!
                    
                    scheduleNativeNotification(triggerTimeMillis, notificationId, title, message)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SCHEDULE_ERROR", e.message, null)
                }
            }
            "cancelNativeNotification" -> {
                try {
                    val notificationId = call.argument<Int>("notificationId")!!
                    cancelNativeNotification(notificationId)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("CANCEL_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun subscribeToDataStore() {
        lifecycleScope.launch {
            dataStoreProvider.waterSettingsFlow.collect { settings ->
                callbackChannel.invokeMethod(K.METHOD_WATER_SETTINGS_CHANGED, settings.asMap())
            }
        }
    }

    private fun createAlarmIfNotRunning() {
        lifecycleScope.launch {
            if (!dataStoreProvider.isAlarmRunning()) {
                setRepeatingWaterAlarm()
                dataStoreProvider.setAlarmRunning(true)
            }
        }
    }

    private fun clearDataStore() {
        lifecycleScope.launch {
            dataStoreProvider.clearPreferences()
            setRepeatingWaterAlarm()
            dataStoreProvider.setAlarmRunning(true)
        }
    }
    
    private fun scheduleNativeNotification(triggerTimeMillis: Long, notificationId: Int, title: String, message: String) {
        // Önce kanalı oluştur
        WaterNotificationReceiver.createNotificationChannel(this)
        
        val intent = Intent(this, WaterNotificationReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("message", message)
            putExtra("notification_id", notificationId)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )
        }
    }
    
    private fun cancelNativeNotification(notificationId: Int) {
        val intent = Intent(this, WaterNotificationReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
    
    // Yeni native alarm sistemi
    private fun scheduleWaterAlarm(alarmId: Int, triggerTimeMillis: Long, title: String, message: String) {
        android.util.Log.d("MainActivity", "🔔 Alarm zamanlanıyor: ID=$alarmId, Time=$triggerTimeMillis")
        
        val intent = Intent(this, WaterAlarmBroadcastReceiver::class.java).apply {
            putExtra("notificationId", alarmId)
            putExtra("title", title)
            putExtra("message", message)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                android.util.Log.d("MainActivity", "✅ Alarm kuruldu (setExactAndAllowWhileIdle)")
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                android.util.Log.d("MainActivity", "✅ Alarm kuruldu (setExact)")
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Alarm kurma hatası: ${e.message}")
        }
    }
    
    private fun cancelAllWaterAlarms() {
        android.util.Log.d("MainActivity", "🔕 Tüm alarmlar iptal ediliyor...")
        
        for (i in 1..60) {
            val intent = Intent(this, WaterAlarmBroadcastReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                i,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
        
        android.util.Log.d("MainActivity", "✅ Tüm alarmlar iptal edildi")
    }
}
