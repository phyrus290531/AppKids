import 'package:flutter/material.dart';

class ReadingGamesScreen extends StatefulWidget {
  @override
  _ReadingGamesScreenState createState() => _ReadingGamesScreenState();
}

class _ReadingGamesScreenState extends State<ReadingGamesScreen> {
  List<Map<String, dynamic>> words = [
    {'word': 'GATO', 'image': 'assets/cat.png'},
    {'word': 'PERRO', 'image': 'assets/dog.png'},
  ];
  String? selectedWord;
  String? selectedImage;

  void _checkMatch() {
    if (selectedWord != null && selectedImage != null) {
      bool isCorrect = (words.firstWhere((item) => item['word'] == selectedWord)['image'] == selectedImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isCorrect ? '¡Correcto!' : 'Intenta de nuevo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lectura')),
      body: Column(
        children: [
          Wrap(
            children: words.map((item) => 
              GestureDetector(
                onTap: () => setState(() => selectedWord = item['word']),
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedWord == item['word'] ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(item['word']),
                ),
              ),
            ).toList(),
          ),
          Wrap(
            children: words.map((item) => 
              GestureDetector(
                onTap: () => setState(() => selectedImage = item['image']),
                child: Image.asset(
                  item['image'],
                  width: 80,
                  color: selectedImage == item['image'] ? Colors.blue[100] : null,
                ),
              ),
            ).toList(),
          ),
          ElevatedButton(
            onPressed: _checkMatch,
            child: Text('Comprobar'),
          ),
        ],
      ),
    );
  }
}