import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'home_screen.dart'; // Agrega este import si no lo tienes

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<int> _pin = [];
  final List<int> _correctPin = [2, 6, 2, 5];
  String _error = '';

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _playAudio();
    _repeatTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      _playAudio();
    });
  }

  void _playAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sonidos/llamar_adulto.mp3'));
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onKeyTap(int value) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(value);
        _error = '';
      });
      if (_pin.length == 4) {
        if (_pin.join() == _correctPin.join()) {
          setState(() {
            _error = '';
          });
        } else {
          setState(() {
            _error = 'PIN incorrecto';
            _pin.clear();
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _error = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinOk = _pin.length == 4 && _pin.join() == _correctPin.join();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double buttonSizeWidth = (screenWidth - 96) / 3;
    double availableHeight = screenHeight - 350;
    double buttonSizeHeight = availableHeight / 4;

    double buttonSize = buttonSizeWidth < buttonSizeHeight ? buttonSizeWidth : buttonSizeHeight;
    if (buttonSize > 80) buttonSize = 80;
    if (buttonSize < 48) buttonSize = 48;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.blue,
onPressed: () {
  Navigator.of(context).pop();
},
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Porfavor, Llama a un adulto",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 24),
          Text(
            "ingresa el el orden de los numeros",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'ComicNeue',
            ),
          ),
          SizedBox(height: 8),
          Text(
            "TWO, SIX, TWO, FIVE",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'ComicNeue',
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 32,
                height: 6,
                decoration: BoxDecoration(
                  color: _pin.length > i ? Colors.blue : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _error,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 48),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ...List.generate(9, (i) {
                  return _PinButton(
                    number: i + 1,
                    onTap: () => _onKeyTap(i + 1),
                    size: buttonSize,
                  );
                }),
                _PinButton(number: 0, onTap: () => _onKeyTap(0), size: buttonSize),
                _PinButton(
                  icon: Icons.backspace,
                  onTap: _onBackspace,
                  size: buttonSize,
                ),
              ],
            ),
          ),
          if (pinOk)
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('selected_profile');
                  Navigator.pushNamedAndRemoveUntil(context, '/profiles', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Cambiar de sesión",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  final int? number;
  final IconData? icon;
  final VoidCallback onTap;
  final double size;

  const _PinButton({this.number, this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white, size: size * 0.5)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}