package com.fabirt.waterreminder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class WaterAlarmBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        android.util.Log.d("WaterAlarmReceiver", "🔔🔔🔔 ALARM TETİKLENDİ! 🔔🔔🔔")
        
        val notificationId = intent.getIntExtra("notificationId", 1)
        val title = intent.getStringExtra("title") ?: "💧 Su İçme Zamanı!"
        val message = intent.getStringExtra("message") ?: "Su içme zamanı geldi!"
        
        android.util.Log.d("WaterAlarmReceiver", "Bildirim gösteriliyor: ID=$notificationId, Title=$title")
        
        // Notification channel oluştur (Android 8+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "water_reminder_native",
                "Su Hatırlatıcı (Native)",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Native su içme hatırlatmaları"
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
        
        // Bildirimi oluştur ve göster
        val notification = NotificationCompat.Builder(context, "water_reminder_native")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .build()
        
        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
            android.util.Log.d("WaterAlarmReceiver", "✅ Bildirim başarıyla gösterildi!")
        } catch (e: Exception) {
            android.util.Log.e("WaterAlarmReceiver", "❌ Bildirim hatası: ${e.message}")
        }
    }
}
