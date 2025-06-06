import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Stack(
            children: [
              // Imagen de fondo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/FondoApp.png', // Asegúrate de tener esta imagen
                  fit: BoxFit.cover,
                ),
              ),
              // Capa semi-transparente para mejorar la legibilidad
              Positioned.fill(
                child: Container(
                  //color: Colors.white.withOpacity(0.8),
                ),
              ),
              // Contenido principal
              SafeArea(
                child: Center(
                  child: Container(
                    width: isWideScreen ? 600 : constraints.maxWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/LogoApp.png',
                          height: isWideScreen ? 300 : 250,
                        ),
                        SizedBox(height: isWideScreen ? 40 : 30),
                        Text(
                          '¡Es Hora de Aprender!',
                          style: TextStyle(
                            fontSize: isWideScreen ? 40 : 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E86C1),
                          ),
                        ),
                        SizedBox(height: isWideScreen ? 60 : 50),
                        GestureDetector(
                          onTapDown: _onTapDown,
                          onTapUp: _onTapUp,
                          onTapCancel: _onTapCancel,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: isWideScreen ? 100 : 80,
                                height: isWideScreen ? 100 : 80,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.play_arrow, 
                                    color: Colors.white, 
                                    size: isWideScreen ? 50 : 40
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}