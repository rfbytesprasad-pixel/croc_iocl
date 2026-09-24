import 'package:flutter/material.dart';

/// Shown while the app is probing candidate IPs to find the ESP
/// (RoInitial → RoApiProbing). Provides feedback so the user knows
/// something is happening.
class ConnectingScreen extends StatelessWidget {
  const ConnectingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFF37022)),
          SizedBox(height: 20),
          Text(
            'Connecting to server…',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}