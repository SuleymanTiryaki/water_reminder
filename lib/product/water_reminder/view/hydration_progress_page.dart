import 'package:flutter/material.dart';
import 'package:waterreminder/product/water_reminder/view/widget/progress_view.dart';
import 'package:waterreminder/product/water_reminder/view/widget/water_input_group.dart';

class HydrationProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            SizedBox(width: double.infinity),
            Text(
              "Mevcut Tüketim",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ProgressView(),
            ),
            WaterInputGroup(),
          ],
        ),
      ),
    );
  }
}
