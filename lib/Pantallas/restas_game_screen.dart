import 'dart:math';
import 'package:flutter/material.dart';

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
    _generateLevel();
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

  void _checkAnswer(int selected) {
    setState(() {
      showResult = true;
      isCorrect = selected == remainingCharacters;
      if (isCorrect) score++;
    });
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
                'assets/images/pizarronfondo.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Column(
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
                    'Hay $totalCharacters personajes.\nSi quito $removedCharacters, ¿cuántos quedan?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
                // Mostrar personajes
                Expanded(
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(totalCharacters, (index) {
                        return AnimatedScale(
                          scale: index < totalCharacters - removedCharacters ? 1.0 : 0.5,
                          duration: Duration(milliseconds: 300),
                          child: Image.asset(characterImage, width: 70, height: 70),
                        );
                      }),
                    ),
                  ),
                ),
                // Opciones
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: options.map((opt) {
                      Color color;
                      if (opt == remainingCharacters && showResult && isCorrect) {
                        color = Colors.greenAccent;
                      } else if (showResult && opt != remainingCharacters) {
                        color = Colors.grey[300]!;
                      } else {
                        color = [Colors.green[200]!, Colors.cyan[100]!, Colors.pink[100]!, Colors.yellow[100]!][options.indexOf(opt)];
                      }
                      return GestureDetector(
                        onTap: showResult ? null : () => _checkAnswer(opt),
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
                              color: showResult && opt == remainingCharacters ? Colors.green : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$opt',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'ComicNeue',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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