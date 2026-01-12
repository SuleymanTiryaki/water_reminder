package com.fabirt.waterreminder

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.time.Instant
import java.time.ZoneId

class DataStoreProvider(private val context: Context) {

    private val waterMilliliters = intPreferencesKey("water_milliliters")
    private val recommendedMilliliters = intPreferencesKey("recommended_milliliters")
    private val lastUpdate = longPreferencesKey("last_update")
    private val notificationEnabled = booleanPreferencesKey("notification_enabled")
    private val alarmRunning = booleanPreferencesKey("alarm_running")
    private val reminderIntervalMinutes = intPreferencesKey("reminder_interval_minutes")

    val waterSettingsFlow: Flow<WaterSettings> = context.dataStore.data.map { preferences ->
        WaterSettings(
                currentMilliliters = preferences[waterMilliliters] ?: 0,
                recommendedMilliliters = preferences[recommendedMilliliters] ?: K.RECOMMENDED_DAILY_WATER_MILLILITERS,
                alarmEnabled = preferences[notificationEnabled] ?: true,
                reminderIntervalMinutes = preferences[reminderIntervalMinutes] ?: 120
        )
    }

    suspend fun verifyDailyReset() {
        context.dataStore.edit { settings ->
            val lastUpdateMillis = settings[lastUpdate] ?: 0L
            val currentMillis = System.currentTimeMillis()

            val lastUpdateDate = Instant.ofEpochMilli(lastUpdateMillis).atZone(ZoneId.systemDefault())
            val currentDate = Instant.ofEpochMilli(currentMillis).atZone(ZoneId.systemDefault())

            if (currentDate.year != lastUpdateDate.year
                    || currentDate.monthValue != lastUpdateDate.monthValue
                    || currentDate.dayOfMonth != lastUpdateDate.dayOfMonth) {
                settings[waterMilliliters] = 0
            }
        }
    }

    suspend fun setWaterMilliliters(milliliters: Int) {
        context.dataStore.edit { settings ->
            val currentMilliliters = settings[waterMilliliters] ?: 0
            settings[waterMilliliters] = currentMilliliters + milliliters
            settings[lastUpdate] = System.currentTimeMillis()
        }
    }

    suspend fun resetWater() {
        context.dataStore.edit { settings ->
            settings[waterMilliliters] = 0
            settings[lastUpdate] = System.currentTimeMillis()
        }
    }

    suspend fun setRecommendedMilliliters(milliliters: Int) {
        context.dataStore.edit { settings ->
            settings[recommendedMilliliters] = milliliters
        }
    }

    suspend fun setNotificationEnabled(enabled: Boolean) {
        context.dataStore.edit { settings ->
            settings[notificationEnabled] = enabled
        }
    }

    suspend fun setReminderIntervalMinutes(minutes: Int) {
        context.dataStore.edit { settings ->
            settings[reminderIntervalMinutes] = minutes
        }
    }

    suspend fun getReminderIntervalMinutes(): Int {
        return context.dataStore.data.map { preferences ->
            preferences[reminderIntervalMinutes] ?: 120
        }.first()
    }

    suspend fun isAlarmRunning(): Boolean {
        return context.dataStore.data.map { preferences ->
            preferences[alarmRunning] ?: false
        }.first()
    }

    suspend fun setAlarmRunning(isRunning: Boolean) {
        context.dataStore.edit { settings ->
            settings[alarmRunning] = isRunning
        }
    }

    suspend fun clearPreferences() {
        context.dataStore.edit { settings ->
            settings.clear()
        }
    }
}

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")
