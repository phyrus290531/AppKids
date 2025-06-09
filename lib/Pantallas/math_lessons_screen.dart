import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'sumas_game_screen.dart';
import 'counting_game_screen.dart';
import 'restas_game_screen.dart';

class MathLessonsScreen extends StatefulWidget {
  @override
  _MathLessonsScreenState createState() => _MathLessonsScreenState();
}

class _MathLessonsScreenState extends State<MathLessonsScreen> {
  int _selectedIndex = 1;  // Initialize to 1 for math tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/FondoApp.png',
              fit: BoxFit.cover,
            ),
          ),
          // Capa semi-transparente
          Positioned.fill(
            child: Container(),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Matemáticas',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Selecciona una lección para continuar:',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _LessonCard(
                        title: 'Aprende a Contar',
                        subtitle: 'Nivel 1',
                        color: Color(0xFFFF7BAC),
                        image: 'assets/images/Numeros.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CountingGameScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _LessonCard(
                        title: 'Sumas Básicas',
                        subtitle: 'Nivel 2',
                        color: Color(0xFF9C7BFF),
                        image: 'assets/images/Sumas.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SumasGameScreen()),
    );
                        },
                      ),
                      SizedBox(height: 16),
                      _LessonCard(
                        title: 'Restas Básicas',
                        subtitle: 'Nivel 3',
                        color: Color(0xFF7B9FFF),
                        image: 'assets/images/Restas.png',
                        isLocked: true,
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => RestasGameScreen()),
                          );
                          // Mostrar mensaje de nivel bloqueado
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Lectura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Matemáticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String image;
  final VoidCallback onTap;
  final bool isLocked;

  const _LessonCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.image,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLocked ? Icons.lock : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}