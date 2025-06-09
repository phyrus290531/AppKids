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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondochido.gif',
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
                // Menú de iconos grandes arriba (igual que home_screen.dart)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Icono Lectura
                      _MenuCircleIcon(
                        icon: Icons.book,
                        label: 'Lectura',
                        selected: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        },
                      ),
                      // Icono Matemáticas
                      _MenuCircleIcon(
                        icon: Icons.calculate,
                        label: 'Matemáticas',
                        selected: true,
                        onTap: () {},
                      ),
                      // Icono Configuración
                      _MenuCircleIcon(
                        icon: Icons.settings,
                        label: 'Configuración',
                        selected: false,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Text(
                          'Matemáticas',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RestasGameScreen()),
                          );
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
    );
  }
}

// Copia este widget desde home_screen.dart para mantener el mismo estilo
class _MenuCircleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuCircleIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              border: selected
                  ? Border.all(color: Colors.purple, width: 3)
                  : null,
            ),
            child: Icon(
              icon,
              color: selected ? Colors.purple : Colors.blue,
              size: 36,
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.purple : Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
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

  // Función para obtener un color más oscuro
  Color _darken(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _darken(color, 0.22), // Borde más oscuro
              width: 3,
            ),
          ),
          child: Row(
            children: [
              // Contenido de texto
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
              ),
              // Imagen dentro de un Card blanco
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          height: 80,
                          width: 80,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}