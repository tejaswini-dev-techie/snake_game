import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_game/Screens/GameScreen/game_screen.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffD2FFFC),
              Color(0xff00B4FF),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Snake Game",
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }
}
