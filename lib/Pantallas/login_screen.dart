import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

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
    _nameController.addListener(() {
      setState(() {
        _isButtonEnabled = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
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
      backgroundColor: Colors.blue, // Mismo azul que el SplashScreen
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Stack(
            children: [
              // Imagen de fondo removida para mantener el azul sólido
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
                          'assets/icons/Logo.png', // Pinguino del SplashScreen
                          height: isWideScreen ? 180 : 140,
                        ),
                        SizedBox(height: isWideScreen ? 40 : 30),
                        Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: isWideScreen ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '¿Cómo te llamas?',
                          style: TextStyle(
                            fontSize: isWideScreen ? 22 : 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            hintText: 'Escribe tu nombre',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTapDown: _isButtonEnabled ? _onTapDown : null,
                          onTapUp: _isButtonEnabled ? _onTapUp : null,
                          onTapCancel: _isButtonEnabled ? _onTapCancel : null,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: isWideScreen ? 100 : 80,
                                height: isWideScreen ? 100 : 80,
                                decoration: BoxDecoration(
                                  color: _isButtonEnabled ? Colors.white : Colors.white38,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: Colors.blue,
                                    size: isWideScreen ? 50 : 40,
                                  ),
                                  onPressed: _isButtonEnabled
                                      ? () {
                                          // Aquí puedes guardar el nombre si lo necesitas
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                          );
                                        }
                                      : null,
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