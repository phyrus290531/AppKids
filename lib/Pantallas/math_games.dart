import 'dart:math';

import 'package:flutter/material.dart';

class MathGamesScreen extends StatefulWidget {
  @override
  _MathGamesScreenState createState() => _MathGamesScreenState();
}

class _MathGamesScreenState extends State<MathGamesScreen> {
  int num1 = 2, num2 = 3;
  int? userAnswer;
  bool isCorrect = false;

  void _checkAnswer() {
    setState(() {
      isCorrect = (userAnswer == num1 + num2);
    });
  }

  void _newQuestion() {
    setState(() {
      num1 = Random().nextInt(10);
      num2 = Random().nextInt(10);
      userAnswer = null;
      isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matemáticas')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '¿Cuánto es $num1 + $num2?',
              style: TextStyle(fontSize: 24),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => userAnswer = int.tryParse(value),
              decoration: InputDecoration(hintText: 'Respuesta'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Comprobar'),
            ),
            if (isCorrect) ...[
              Text('¡Correcto! 🎉', style: TextStyle(color: Colors.green, fontSize: 20)),
              ElevatedButton(
                onPressed: _newQuestion,
                child: Text('Siguiente Pregunta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}