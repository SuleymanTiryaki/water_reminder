import 'package:flutter/material.dart';
import 'package:waterreminder/product/water_reminder/model/water_input.dart';

class WaterButton extends StatelessWidget {
  final WaterInput input;
  final ValueChanged<WaterInput> onPressed;

  const WaterButton({
    Key? key,
    required this.input,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: TextButton.icon(
          onPressed: () => onPressed(input),
          icon: Icon(input.icon),
          label: Text("${input.milliliters} ml"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(input.backgroundColor),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            overlayColor:
                MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
            elevation: MaterialStateProperty.all(2),
            shadowColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.3)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            // Butonun genişliğini doldurmasını sağla
            minimumSize: MaterialStateProperty.all(Size(double.infinity, 0)),
          ),
        ),
      ),
    );
  }
}
