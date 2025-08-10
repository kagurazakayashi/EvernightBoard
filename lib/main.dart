import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: FullScreenText()));
  }
}

class FullScreenText extends StatelessWidget {
  const FullScreenText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.redAccent,
        alignment: Alignment.center,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: Text(
            '神楽坂雅詩\nかぐらざか みやび\nKagurazakaMiyabi',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
