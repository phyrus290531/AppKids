import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart'; // Asegúrate de importar la pantalla de inicio
import 'math_lessons_screen.dart'; // Asegúrate de importar la pantalla de lecciones de matemáticas

class CountingGameScreen extends StatefulWidget {
  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen> {
  int currentLevel = 0;
  int score = 0;
  final int totalLevels = 10;
  List<int> sequence = [];
  List<int> missingIndexes = [];
  List<int> options = [];
  Map<int, int?> userAnswers = {};
  bool showResult = false;

  late AudioPlayer backgroundPlayer;
  late AudioPlayer numberPlayer;
  late AudioPlayer periodicPlayer;
  late AudioPlayer effectPlayer; // Nuevo para efectos de correcto/incorrecto

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
    numberPlayer.dispose();
    backgroundPlayer.dispose();
    periodicPlayer.dispose();
    effectPlayer.dispose(); // Liberar recursos
    super.dispose();
  }

  void _initializeAudio() async {
    backgroundPlayer = AudioPlayer();
    numberPlayer = AudioPlayer();
    periodicPlayer = AudioPlayer();
    effectPlayer = AudioPlayer(); // Inicializar

    // Reproduce la canción de fondo
    await backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await backgroundPlayer.play(AssetSource('sonidos/puzzlegame.mp3'));

    // Reproduce el audio "Contar.mp3" cada 10 segundos
    periodicPlayer.setReleaseMode(ReleaseMode.stop);
    periodicPlayer.play(AssetSource('sonidos/Contar.mp3'));
    Future.delayed(Duration(seconds: 20), () {
      periodicPlayer.play(AssetSource('sonidos/Contar.mp3'));
    });
  }

  void _playNumberAudio(int number) async {
    String audioFile = 'sonidos/${_getNumberAudioFile(number)}.mp3';
    await numberPlayer.play(AssetSource(audioFile));
  }

  String _getNumberAudioFile(int number) {
    switch (number) {
      case 1:
        return 'uno';
      case 2:
        return 'Dos';
      case 3:
        return 'Tres';
      case 4:
        return 'Cuatro';
      case 5:
        return 'Cinco';
      case 6:
        return 'Seis';
      case 7:
        return 'Siete';
      case 8:
        return 'Ocho';
      case 9:
        return 'Nueve';
      case 10:
        return 'Diez';
      default:
        return '';
    }
  }

  void _generateLevel() {
    // Cada nivel aumenta la cantidad de huecos (1 a 4)
    int holes = min(1 + currentLevel ~/ 3, 4);
    sequence = List.generate(10, (i) => i + 1);
    List<int> idxs = List.generate(10, (i) => i)..shuffle();
    missingIndexes = idxs.take(holes).toList()..sort();
    userAnswers = {for (var idx in missingIndexes) idx: null};

    // Opciones: los números faltantes + algunos distractores
    Set<int> opts = missingIndexes.map((i) => sequence[i]).toSet();
    while (opts.length < 4) {
      int n = Random().nextInt(10) + 1;
      if (!sequence.asMap().entries.any((e) => userAnswers[e.key] == n)) {
        opts.add(n);
      }
    }
    options = opts.toList()..shuffle();

    showResult = false;
    setState(() {});
  }

  // Cambia _checkAnswers para permitir reintento y reproducir sonidos
  void _checkAnswers() async {
    setState(() {
      showResult = true;
    });

    bool allCorrect = true;
    userAnswers.forEach((idx, val) {
      if (val != sequence[idx]) allCorrect = false;
    });

    if (allCorrect) {
      await effectPlayer.play(AssetSource('sonidos/correcto.mp3'));
      score++;
      Future.delayed(Duration(seconds: 1), () {
        if (currentLevel < totalLevels - 1) {
          setState(() {
            currentLevel++;
            showResult = false;
          });
          _generateLevel();
        } else {
          _showFinalDialog();
        }
      });
    } else {
      await effectPlayer.play(AssetSource('sonidos/incorrecto.mp3'));
      // Permitir reintentar: solo resalta incorrecto pero no avanza
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          showResult = false;
        });
      });
    }
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
          '¡Completaste los $totalLevels niveles!\nPuntaje: $score/$totalLevels',
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MathLessonsScreen()),
                (route) => false,
              );
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
                'assets/images/Fondosalon2.jpg',
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
                      // Barra de progreso
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: LinearProgressIndicator(
                          value: (currentLevel + 1) / totalLevels,
                          backgroundColor: Colors.grey[300],
                          color: Colors.purple,
                          minHeight: 8,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                        child: Text(
                          '¿Qué número falta?',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ComicNeue',
                            shadows: [Shadow(color: Colors.white, blurRadius: 4)],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Secuencia de números con huecos dentro de un Card
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(10, (i) {
                                  if (missingIndexes.contains(i)) {
                                    int? answer = userAnswers[i];
                                    return GestureDetector(
                                      onTap: () {
                                        if (answer != null) _playNumberAudio(answer);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: answer == null
                                                ? Colors.yellow[100]
                                                : (showResult
                                                    ? (answer == sequence[i]
                                                        ? Colors.greenAccent
                                                        : Colors.redAccent)
                                                    : Colors.cyan[100]),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.deepOrange,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              answer?.toString() ?? '?',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: answer == null
                                                    ? Colors.deepOrange
                                                    : (showResult
                                                        ? (answer == sequence[i]
                                                            ? Colors.green[900]
                                                            : Colors.red[900])
                                                        : Colors.deepOrange),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () => _playNumberAudio(sequence[i]),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.purple,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              sequence[i].toString(),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple[800],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Opciones con breathing animation debajo del Card
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 32.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 16,
                          children: options.map((opt) {
                            // Busca si la opción ya está asignada a algún hueco
                            int? selectedIdx = userAnswers.entries.firstWhere(
                              (e) => e.value == opt,
                              orElse: () => MapEntry(-1, null),
                            ).key;

                            return _BreathingButton(
                              isSelected: selectedIdx != -1,
                              showResult: showResult,
                              isCorrect: showResult && missingIndexes.any((idx) => userAnswers[idx] == opt && userAnswers[idx] == sequence[idx]),
                              label: '$opt',
                              onTap: showResult
                                  ? null
                                  : () {
                                      setState(() {
                                        if (selectedIdx != -1) {
                                          // Si ya está seleccionada, deselecciona
                                          userAnswers[selectedIdx] = null;
                                        } else {
                                          // Asigna al primer hueco vacío
                                          int? idx = userAnswers.entries
                                              .firstWhere((e) => e.value == null, orElse: () => MapEntry(-1, null))
                                              .key;
                                          if (idx != -1) {
                                            userAnswers[idx] = opt;
                                          }
                                        }
                                      });
                                    },
                            );
                          }).toList(),
                        ),
                      ),
                      // Botón para comprobar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: showResult || userAnswers.values.any((v) => v == null)
                              ? null
                              : _checkAnswers,
                          child: Text(
                            'Comprobar',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Botón de cerrar
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(Icons.close, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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