import 'package:flutter/material.dart';
import 'Pantallas/profile_selector_screen.dart';
import 'Pantallas/profile_name_screen.dart';
import 'Pantallas/profile_age_screen.dart';
import 'Pantallas/profile_avatar_screen.dart';
import 'Pantallas/settings_screen.dart';
import 'Pantallas/math_lessons_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprende Jugando',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        '/profiles': (context) => ProfileSelectorScreen(),
        '/profile_name': (context) => ProfileNameScreen(),
        '/profile_age': (context) => ProfileAgeScreen(),
        '/profile_avatar': (context) => ProfileAvatarScreen(),
        '/settings': (context) => SettingsScreen(),
        '/math_lessons': (context) => MathLessonsScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/profiles');
    });

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/Logo.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
