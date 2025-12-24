import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 74),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
      ),
    );
  }
}
