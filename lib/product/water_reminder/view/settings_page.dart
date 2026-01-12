import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:waterreminder/product/water_reminder/cubit/water_cubit.dart';
import 'package:waterreminder/data/notification/notification_service.dart';
import 'package:waterreminder/product/water_reminder/view/widget/rolling_switch_button.dart';
import 'package:waterreminder/util/dialog.dart';
import 'package:waterreminder/util/num_extension.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    await _notificationService.requestPermission();
  }

  Future<void> _handleAlarmToggle(bool value) async {
    if (value) {
      // 1. Bildirim iznini kontrol et ve iste
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          if (!mounted) return;
          _showPermissionDialog('Bildirim İzni', 
            'Hatırlatmaların çalışması için bildirim izni gereklidir.\n\nLütfen ayarlardan bildirim iznini açın.');
          return;
        }
      }

      // 2. Exact Alarm iznini kontrol et (Android 12+)
      try {
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          if (!mounted) return;
          _showPermissionDialog('Tam Zamanlı Alarm İzni', 
            'Bildirimlerin tam zamanında gelmesi için bu izin gereklidir.\n\nLütfen ayarlardan "Alarms & reminders" iznini açın.');
          return;
        }
      } catch (e) {
        print('Exact alarm izni kontrolü hatası (Android 8-11 için normal): $e');
      }

      // 3. Pil optimizasyonunu kontrol et
      try {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
        if (!batteryStatus.isGranted) {
          if (!mounted) return;
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Pil Optimizasyonu'),
              content: Text(
                'Bildirimlerin düzenli çalışması için pil optimizasyonunu kapatmanız önerilir.\n\n'
                '• Ayarlar > Pil > Pil optimizasyonu\n'
                '• Bu uygulamayı bulun\n'
                '• "Optimize etme" seçeneğini seçin\n\n'
                'Şimdi ayarlara gitmek ister misiniz?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Daha Sonra'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    openAppSettings();
                  },
                  child: Text('Ayarlara Git'),
                ),
              ],
            ),
          );
          // Pil optimizasyonu opsiyonel, kullanıcı "Daha Sonra" diyebilir
          if (shouldContinue == null || shouldContinue == false) {
            // Yine de devam et ama uyarı göster
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Pil optimizasyonu açık olduğu için bildirimler gecikebilir.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        print('Battery optimization kontrolü hatası: $e');
      }
    }

    // İzin varsa veya alarm kapatılıyorsa, işleme devam et
    context.read<WaterCubit>().changeAlarmEnabled(value);
  }

  Future<void> _showPermissionDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterCubit>();
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(width: double.infinity),
              // Header text removed as it's in AppBar now
              Padding(
                padding: EdgeInsets.only(left: 6, right: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Hatırlatmalar"),
                    ),
                    RollingSwitchButton(
                      value: bloc.state.alarmEnabled,
                      colorOff: theme.colorScheme.error,
                      onChange: (value) => _handleAlarmToggle(value),
                    ),
                  ],
                ),
              ),
              if (bloc.state.alarmEnabled)
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 6, right: 6),
                  child: Text(
                    "💡 İpucu: En iyi sonuç için Ayarlar > Pil > Pil optimizasyonu menüsünden bu uygulamayı optimize etme seçeneğini kapatın.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 32),
              TextButton(
                onPressed: () => showConsumptionDialog(context),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      theme.primaryColor.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Günlük tüketim",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        bloc.state.recommendedMilliliters.asMilliliters(),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showReminderIntervalDialog(context),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      theme.primaryColor.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Hatırlatma aralığı",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        _formatInterval(bloc.state.reminderIntervalMinutes),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _pickTime(context,
                    isStartTime: true, current: bloc.state.startTime),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      theme.primaryColor.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Başlangıç Zamanı",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        "${bloc.state.startTime.format(context)}",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _pickTime(context,
                    isStartTime: false, current: bloc.state.endTime),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      theme.primaryColor.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Bitiş Zamanı",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        "${bloc.state.endTime.format(context)}",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _notificationService.showTestNotification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Test bildirimi gönderildi!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Test Bildirimi Gönder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) {
      return "$minutes dk";
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return "$hours saat";
      } else {
        return "$hours saat $remainingMinutes dk";
      }
    }
  }

  Future<void> showReminderIntervalDialog(BuildContext context) async {
    final bloc = context.read<WaterCubit>();
    final currentInterval = bloc.state.reminderIntervalMinutes;

    await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Hatırlatma Aralığı"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIntervalOption(
                  dialogContext, bloc, 10, "10 dakika (Test)", currentInterval),
              _buildIntervalOption(
                  dialogContext, bloc, 60, "1 saat", currentInterval),
              _buildIntervalOption(
                  dialogContext, bloc, 120, "2 saat", currentInterval),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalOption(BuildContext context, WaterCubit bloc,
      int minutes, String label, int currentInterval) {
    return ListTile(
      title: Text(label),
      onTap: () {
        bloc.setReminderInterval(minutes);
        Navigator.pop(context, minutes);
      },
      selected: currentInterval == minutes,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  Future<void> _pickTime(BuildContext context,
      {required bool isStartTime, required TimeOfDay current}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      if (isStartTime) {
        context.read<WaterCubit>().setStartTime(picked);
      } else {
        context.read<WaterCubit>().setEndTime(picked);
      }
    }
  }
}
