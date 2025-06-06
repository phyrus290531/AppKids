import 'package:flutter/material.dart';
import 'math_games.dart';
import 'reading_games.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
            child: Container(
              //color: Colors.white.withOpacity(0.8),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Lectura',
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
                        title: 'El ABC',
                        subtitle: 'Nivel 1',
                        color: Color(0xFFFF7BAC),
                        image: 'assets/images/abc_lesson.png',
                        onTap: () {
                          // Navegación a la lección ABC
                        },
                      ),
                      SizedBox(height: 16),
                      _LessonCard(
                        title: 'Las Vocales',
                        subtitle: 'Nivel 2',
                        color: Color(0xFF9C7BFF),
                        image: 'assets/images/vocales_lesson.jpg',
                        onTap: () {
                          // Navegación a la lección de vocales
                        },
                      ),
                      SizedBox(height: 16),
                      _LessonCard(
                        title: 'Las Sílabas',
                        subtitle: 'Nivel 3',
                        color: Color(0xFF7B9FFF),
                        image: 'assets/images/silabas_lesson.jpg',
                        isLocked: true,
                        onTap: () {
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