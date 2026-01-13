import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_scheduler/notification_scheduler.dart';

import 'package:waterreminder/product/water_reminder/cubit/water_cubit.dart';
import 'package:waterreminder/product/water_reminder/service/water_service.dart';
import 'package:waterreminder/product/water_reminder/view/home_page.dart';
import 'package:waterreminder/product/water_reminder/view/theme/app_theme.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _service = WaterService();
  bool _notificationsChecked = false; // Sadece bir kez kontrol et

  @override
  void initState() {
    super.initState();
    _service.subscribeToDataStore();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // iOS için arka plan yenilemesini SADECE BİR KEZ kontrol et
    if (Platform.isIOS && !_notificationsChecked) {
      _notificationsChecked = true;
      await NotificationScheduler.checkAndRefresh();
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WaterCubit(_service),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Water Reminder',
        theme: AppTheme.light,
        home: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: HomePage(),
        ),
      ),
    );
  }
}
