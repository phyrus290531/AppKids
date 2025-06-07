import 'package:flutter/material.dart';
import 'Pantallas/home_screen.dart';
import 'Pantallas/math_games.dart';
import 'Pantallas/reading_games.dart';
import 'Pantallas/login_screen.dart';

void main() {
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
      home: SplashScreen(), // Cambié aquí para que inicie con el SplashScreen
      routes: {
        '/home': (context) => HomeScreen(),
        '/math': (context) => MathGamesScreen(),
        '/reading': (context) => ReadingGamesScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

// Widget para pantalla de carga inicial (SplashScreen) con logo personalizado
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      // Después de 2 segundos, redirige al LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.blue, // Fondo azul
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/Logo.png', // Usa tu imagen personalizada
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
