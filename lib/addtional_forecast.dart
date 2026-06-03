import 'package:flutter/material.dart';

class Addtionalinfo extends StatelessWidget {
  final IconData icon;
  final String lable;
  final String value;
  const Addtionalinfo({
    super.key,
    required this.icon,
    required this.lable,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(width: 8),
        Text(lable),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
