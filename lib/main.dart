import 'package:flutter/material.dart';
import 'package:snake_game/Screens/GameScreen/game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:snake_game/Screens/SplashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBrpgA4X5ebmgy3aLbAzL34twbparrig3g",
        authDomain: "snakegame-7de88.firebaseapp.com",
        projectId: "snakegame-7de88",
        storageBucket: "snakegame-7de88.appspot.com",
        messagingSenderId: "613830546180",
        appId: "1:613830546180:web:380834cd167a4e6dd33651",
        measurementId: "G-JKZNFPCHZ4"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const SplashScreenView(),
    );
  }
}
