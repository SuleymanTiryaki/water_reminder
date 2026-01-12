import 'package:flutter/material.dart';

class WaterInput {
  final int milliliters;
  final IconData icon;
  final Color backgroundColor;

  WaterInput({
    required this.milliliters,
    required this.icon,
    required this.backgroundColor,
  });

  factory WaterInput.small() = _Small;
  factory WaterInput.regular() = _Regular;
  factory WaterInput.medium() = _Medium;
  factory WaterInput.large() = _Large;
}

class _Small extends WaterInput {
  _Small()
      : super(
          milliliters: 180,
          icon: Icons.local_drink_outlined,
          backgroundColor: Color(0xFF64B5F6), // Blue 300
        );
}

class _Regular extends WaterInput {
  _Regular()
      : super(
          milliliters: 250,
          icon: Icons.local_cafe_outlined,
          backgroundColor: Color(0xFF42A5F5), // Blue 400
        );
}

class _Medium extends WaterInput {
  _Medium()
      : super(
          milliliters: 500,
          icon: Icons.local_drink_rounded,
          backgroundColor: Color(0xFF2196F3), // Blue 500
        );
}

class _Large extends WaterInput {
  _Large()
      : super(
          milliliters: 750,
          icon: Icons.opacity,
          backgroundColor: Color(0xFF1E88E5), // Blue 600
        );
}
