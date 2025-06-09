import 'dart:async'; // <-- IMPORTANTE
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RestasGameScreen extends StatefulWidget {
  @override
  State<RestasGameScreen> createState() => _RestasGameScreenState();
}

class _RestasGameScreenState extends State<RestasGameScreen> {
  int currentLevel = 0;
  int score = 0;
  final int totalLevels = 10;
  late int totalCharacters;
  late int removedCharacters;
  late int remainingCharacters;
  late String characterImage;
  late List<int> options;
  bool showResult = false;
  bool isCorrect = false;

  late AudioPlayer backgroundPlayer;
  late AudioPlayer periodicPlayer;
  late AudioPlayer effectPlayer; // Nuevo para efectos de correcto/incorrecto
  Timer? periodicTimer;

  final List<String> characters = [
    'assets/images/oso.png',
    'assets/images/elefante.png',
    'assets/images/gato.png',
    'assets/images/perro.png',
    'assets/images/pato.png',
    'assets/images/mono.png',
    'assets/images/raton.png',
    'assets/images/cerdo.png',
    'assets/images/leon.png',
    'assets/images/tigre.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _generateLevel();
  }

  @override
  void dispose() {
    backgroundPlayer.stop();
    periodicPlayer.stop();
    effectPlayer.stop(); // Detener efectos de sonido
    backgroundPlayer.dispose();
    periodicPlayer.dispose();
    effectPlayer.dispose(); // Liberar recursos
    periodicTimer?.cancel();
    super.dispose();
  }

  void _initializeAudio() async {
    backgroundPlayer = AudioPlayer();
    periodicPlayer = AudioPlayer();
    effectPlayer = AudioPlayer(); // Inicializar reproductor de efectos

    // Música de fondo en loop
    await backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await backgroundPlayer.play(AssetSource('sonidos/puzzlegame.mp3'));

    // Audio de instrucciones al inicio y cada 20 segundos
    await periodicPlayer.setReleaseMode(ReleaseMode.stop);
    await periodicPlayer.play(AssetSource('sonidos/Restas.mp3'));
    periodicTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
      await periodicPlayer.seek(Duration.zero);
      await periodicPlayer.play(AssetSource('sonidos/Restas.mp3'));
    });
  }

  void _checkAnswer(int selected) async {
    setState(() {
      showResult = true;
      isCorrect = selected == remainingCharacters;
      if (isCorrect) {
        score++;
        // Reproducir audio de correcto
        effectPlayer.play(AssetSource('sonidos/correcto.mp3'));
        Future.delayed(Duration(seconds: 1), () {
          if (currentLevel < totalLevels - 1) {
            setState(() {
              currentLevel++;
            });
            _generateLevel();
          } else {
            _showFinalDialog();
          }
        });
      } else {
        // Reproducir audio de incorrecto
        effectPlayer.play(AssetSource('sonidos/incorrecto.mp3'));
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            showResult = false; // Permite otro intento
          });
        });
      }
    });
  }

  void _generateLevel() {
    final rand = Random();
    totalCharacters = rand.nextInt(6) + 5; // Total entre 5 y 10
    removedCharacters = rand.nextInt(totalCharacters - 1) + 1; // Removidos entre 1 y total-1
    remainingCharacters = totalCharacters - removedCharacters;

    characterImage = characters[rand.nextInt(characters.length)];

    // Generar opciones
    Set<int> opts = {remainingCharacters};
    while (opts.length < 4) {
      opts.add(rand.nextInt(totalCharacters + 1));
    }
    options = opts.toList()..shuffle();

    showResult = false;
    isCorrect = false;
    setState(() {});
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            '¡Juego Terminado!',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: Text(
          '¡Respondiste $score de $totalLevels correctamente!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondomatematicas.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.lightBlue, size: 32),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                height: 18,
                                width: (MediaQuery.of(context).size.width - 60) * ((currentLevel + 1) / totalLevels),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreen,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                      child: Text(
                        'Hay $totalCharacters personajes.\nSi quito $removedCharacters, ¿cuántos quedan?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ComicNeue',
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Mostrar personajes
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35, // Reducido de 0.4 a 0.35
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calcula el tamaño adaptativo para los personajes
                              double imageSize = MediaQuery.of(context).size.width * 0.2;
                              imageSize = imageSize.clamp(60.0, 80.0); // Limita el tamaño entre 60 y 80

                              return Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10, // Reducido de 15 a 10
                                runSpacing: 10, // Reducido de 15 a 10
                                children: List.generate(totalCharacters, (index) {
                                  return AnimatedScale(
                                    scale: index < totalCharacters - removedCharacters ? 1.0 : 0.5,
                                    duration: Duration(milliseconds: 300),
                                    child: Container(
                                      width: imageSize,
                                      height: imageSize,
                                      child: Image.asset(
                                        characterImage,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Opciones con breathing animation
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 32.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 16,
                        children: options.map((opt) {
                          return _BreathingButton(
                            isSelected: false,
                            showResult: showResult,
                            isCorrect: showResult && opt == remainingCharacters,
                            label: '$opt',
                            onTap: showResult ? null : () => _checkAnswer(opt),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botón de cerrar
          ],
        ),
      ),
    );
  }
}

// Breathing Button Widget
class _BreathingButton extends StatefulWidget {
  final bool isSelected;
  final bool showResult;
  final bool isCorrect;
  final String label;
  final VoidCallback? onTap;

  const _BreathingButton({
    required this.isSelected,
    required this.showResult,
    required this.isCorrect,
    required this.label,
    this.onTap,
  });

  @override
  State<_BreathingButton> createState() => _BreathingButtonState();
}

class _BreathingButtonState extends State<_BreathingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.isCorrect) {
      color = Colors.greenAccent;
    } else if (widget.showResult) {
      color = Colors.grey[300]!;
    } else {
      color = widget.isSelected ? Colors.green[200]! : Colors.pink[100]!;
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 80,
          height: 50,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 2),
              )
            ],
            border: Border.all(
              color: widget.isCorrect ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'ComicNeue',
            ),
          ),
        ),
      ),
    );
  }
}