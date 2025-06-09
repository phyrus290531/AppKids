import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SumasGameScreen extends StatefulWidget {
  @override
  State<SumasGameScreen> createState() => _SumasGameScreenState();
}

class _SumasGameScreenState extends State<SumasGameScreen> {
  int currentProblem = 0;
  int score = 0;
  late int num1;
  late int num2;
  late int correctAnswer;
  late List<int> options;
  bool showResult = false;
  bool isCorrect = false;

  late AudioPlayer backgroundPlayer;
  late AudioPlayer periodicPlayer;
  late AudioPlayer effectPlayer;

  // Lista de personajes y colores asociados
  final List<Map<String, dynamic>> characters = [
    {'img': 'assets/images/oso.png', 'color': Colors.brown[200]},
    {'img': 'assets/images/elefante.png', 'color': Colors.blue[100]},
    {'img': 'assets/images/gato.png', 'color': Colors.orange[100]},
    {'img': 'assets/images/perro.png', 'color': Colors.grey[300]},
    {'img': 'assets/images/pato.png', 'color': Colors.yellow[100]},
    {'img': 'assets/images/mono.png', 'color': Colors.brown[100]},
    {'img': 'assets/images/raton.png', 'color': Colors.grey[200]},
    {'img': 'assets/images/cerdo.png', 'color': Colors.pink[100]},
    {'img': 'assets/images/leon.png', 'color': Colors.amber[200]},
    {'img': 'assets/images/tigre.png', 'color': Colors.orange[200]},
  ];

  List<Map<String, dynamic>> currentCharacters = [];

  Timer? periodicTimer;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _generateProblem();
  }

  @override
  void dispose() {
    // Detén y libera los reproductores de audio
    if (backgroundPlayer.state != PlayerState.stopped) {
      backgroundPlayer.stop();
    }
    backgroundPlayer.dispose();

    if (periodicPlayer.state != PlayerState.stopped) {
      periodicPlayer.stop();
    }
    periodicPlayer.dispose();

    effectPlayer.dispose();

    // Cancela el Timer si está activo
    periodicTimer?.cancel();

    super.dispose();
  }

  void _initializeAudio() async {
    try {
      backgroundPlayer = AudioPlayer();
      periodicPlayer = AudioPlayer();
      effectPlayer = AudioPlayer();

      // Música de fondo
      await backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await backgroundPlayer.setSourceAsset('sonidos/puzzlegame.mp3');
      await backgroundPlayer.resume();

      // Audio de instrucciones cada 20 segundos
      await periodicPlayer.setSourceAsset('sonidos/sumas.mp3');
      await periodicPlayer.resume();
      
      // Configura el timer para reproducir cada 20 segundos
      periodicTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
        if (periodicPlayer.state != PlayerState.stopped) {
          await periodicPlayer.seek(Duration.zero);
          await periodicPlayer.resume();
        }
      });

    } catch (e) {
      print('Error al inicializar audio: $e');
    }
  }

  void _generateProblem() {
    final rand = Random();
    num1 = rand.nextInt(5) + 2; // 2 a 6
    num2 = rand.nextInt(5) + 2; // 2 a 6
    correctAnswer = num1 + num2;

    // Opciones aleatorias
    Set<int> opts = {correctAnswer};
    while (opts.length < 4) {
      opts.add(rand.nextInt(11) + 2); // 2 a 12
    }
    options = opts.toList()..shuffle();

    // Selecciona personajes aleatorios
    currentCharacters = [];
    List<Map<String, dynamic>> shuffled = List.from(characters)..shuffle();
    for (int i = 0; i < correctAnswer; i++) {
      currentCharacters.add(shuffled[i % shuffled.length]);
    }

    showResult = false;
    isCorrect = false;
    setState(() {});
  }

  void _checkAnswer(int selected) async {
    setState(() {
      showResult = true;
      isCorrect = selected == correctAnswer;
      if (isCorrect) score++;
    });
    await effectPlayer.play(
      AssetSource(isCorrect ? 'sonidos/correcto.mp3' : 'sonidos/incorrecto.mp3'),
    );
    Future.delayed(Duration(seconds: 1), () {
      if (isCorrect) {
        if (currentProblem < 9) {
          setState(() {
            currentProblem++;
          });
          _generateProblem();
        } else {
          _showFinalDialog();
        }
      } else {
        setState(() {
          showResult = false;
        });
      }
    });
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
          '¡Respondiste $score de 10 sumas correctamente!',
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Barra de progreso y botón de regreso (igual que counting_game_screen.dart)
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
                                  width: (MediaQuery.of(context).size.width - 60) * ((currentProblem + 1) / 10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
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
                          '¿Cuántos personajes hay?',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ComicNeue',
                            shadows: [Shadow(color: Colors.white, blurRadius: 4)],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Personajes en Cards de color
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: currentCharacters.map((char) {
                              return Card(
                                color: char['color'] ?? Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(char['img'], width: 60, height: 60),
                                ),
                              );
                            }).toList(),
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
                            bool isSelected = false; // Puedes agregar lógica si quieres resaltar la seleccionada
                            return _BreathingButton(
                              isSelected: isSelected,
                              showResult: showResult,
                              isCorrect: showResult && opt == correctAnswer && isCorrect,
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
            ),
          ],
        ),
      ),
    );
  }
}

// Breathing animation button widget
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
                color: Colors.black12,
                blurRadius: 4,
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
              fontSize: 24,
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