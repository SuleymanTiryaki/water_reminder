import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterreminder/product/water_reminder/model/water_input.dart';
import 'package:waterreminder/product/water_reminder/model/water_settings.dart';
import 'package:waterreminder/product/water_reminder/service/water_service.dart';

class WaterCubit extends Cubit<WaterSettings> {
  WaterCubit(this._service) : super(WaterSettings.initial()) {
    _subscription = _service.waterSettings.listen((event) {
      emit(event);
    });
  }

  final WaterService _service;
  StreamSubscription? _subscription;
  int? _lastAddedAmount;

  int get currentWater => state.currentMilliliters;
  int get remainigWater =>
      state.currentMilliliters <= state.recommendedMilliliters
          ? state.recommendedMilliliters - state.currentMilliliters
          : 0;
  double get progress =>
      state.currentMilliliters / state.recommendedMilliliters;
  
  bool get canUndo => _lastAddedAmount != null;

  Future<void> drinkWater(WaterInput input) async {
    _lastAddedAmount = input.milliliters;
    await _service.drinkWater(input.milliliters);
    // State değişikliğini emit etmek gerekebilir ama service.listen zaten bunu yapıyor.
    // Ancak canUndo state'i değiştiği için UI'ı tetiklemek gerekebilir.
    // WaterSettings'de canUndo diye bir alan yok, bu yüzden Cubit state'i sadece WaterSettings.
    // UI tarafında setState kullanılıyor olabilir veya bu bilgiyi bir şekilde geçirmemiz lazım.
    // Şimdilik sadece bellekte tutuyoruz.
  }

  Future<void> undoLastIntake() async {
    if (_lastAddedAmount != null) {
      await _service.removeWater(_lastAddedAmount!);
      _lastAddedAmount = null;
    }
  }

  Future<void> setReminderInterval(int minutes) async {
    await _service.setReminderInterval(minutes);
  }

  Future<void> setRecommendedMilliliters(int milliliters) async {
    await _service.setRecommendedMilliliters(milliliters);
  }

  Future<void> changeAlarmEnabled(bool enabled) async {
    await _service.changeAlarmEnabled(enabled);
  }

  Future<void> setStartTime(TimeOfDay time) async {
    await _service.setStartTime(time);
  }

  Future<void> setEndTime(TimeOfDay time) async {
    await _service.setEndTime(time);
  }

  Future<void> clearDataStore() async {
    await _service.clearDataStore();
  }

  Future<void> resetDailyIntake() async {
    await _service.resetDailyIntake();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
