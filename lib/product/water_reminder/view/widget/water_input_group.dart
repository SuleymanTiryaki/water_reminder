import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterreminder/product/water_reminder/cubit/water_cubit.dart';
import 'package:waterreminder/product/water_reminder/model/water_input.dart';
import 'package:waterreminder/product/water_reminder/view/widget/water_button.dart';

class WaterInputGroup extends StatefulWidget {
  @override
  State<WaterInputGroup> createState() => _WaterInputGroupState();
}

class _WaterInputGroupState extends State<WaterInputGroup> {
  @override
  Widget build(BuildContext context) {
    void addInput(WaterInput value) {
      context.read<WaterCubit>().drinkWater(value);
    }

    void undoInput() {
      // Sadece günlük su tüketimini sıfırla
      context.read<WaterCubit>().resetDailyIntake();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Günlük tüketim sıfırlandı"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WaterButton(
                input: WaterInput.small(),
                onPressed: addInput,
              ),
            ),
            Expanded(
              child: WaterButton(
                input: WaterInput.regular(),
                onPressed: addInput,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: WaterButton(
                input: WaterInput.medium(),
                onPressed: addInput,
              ),
            ),
            Expanded(
              child: WaterButton(
                input: WaterInput.large(),
                onPressed: addInput,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Her zaman göster
        TextButton.icon(
          onPressed: undoInput,
          icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
          label: Text(
            "Tüketimi Sıfırla",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
