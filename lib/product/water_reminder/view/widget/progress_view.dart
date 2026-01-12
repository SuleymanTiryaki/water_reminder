import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterreminder/product/water_reminder/cubit/water_cubit.dart';
import 'package:waterreminder/product/water_reminder/view/widget/progress_painter.dart';

import '../../../../util/num_extension.dart';

class ProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterCubit>();
    final theme = Theme.of(context);

    final gradient = SweepGradient(
      transform: GradientRotation(pi * 3 / 2),
      colors: [
        theme.colorScheme.secondary.withOpacity(0.5),
        theme.colorScheme.secondary.withOpacity(0.5),
      ],
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: bloc.progress),
      builder: (context, value, child) {
        return CustomPaint(
          painter: ProgressPainter(
            gradient: gradient,
            inactiveColor: theme.unselectedWidgetColor,
            progress: value.clamp(0.0, 1.0),
          ),
          child: _DataColumn(progress: value),
        );
      },
    );
  }
}

class _DataColumn extends StatelessWidget {
  final double progress;

  const _DataColumn({
    Key? key,
    required this.progress,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.watch<WaterCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: double.infinity),
        Text(
          "${(progress * 100).toInt()} %",
          style: theme.textTheme.displayLarge,
        ),
        SizedBox(height: 4),
        Text(
          bloc.state.currentMilliliters.asMilliliters(),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 8),
        Text(
          bloc.remainigWater.asMilliliters(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
