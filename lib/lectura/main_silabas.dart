import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SilabasJuegoApp());
}

class SilabasJuegoApp extends StatelessWidget {
  const SilabasJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Sílabas',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SilabasGame(),
    );
  }
}

class SilabasGame extends StatefulWidget {
  const SilabasGame({super.key});

  @override
  State<SilabasGame> createState() => _SilabasGameState();
}

class _SilabasGameState extends State<SilabasGame> {
  // Lista de palabras de dos sílabas y sus sílabas separadas
  final List<Map<String, dynamic>> _palabras = [
    {'palabra': 'casa', 'silabas': ['ca', 'sa']},
    {'palabra': 'mesa', 'silabas': ['me', 'sa']},
    {'palabra': 'luna', 'silabas': ['lu', 'na']},
    {'palabra': 'pato', 'silabas': ['pa', 'to']},
    {'palabra': 'sapo', 'silabas': ['sa', 'po']},
    {'palabra': 'nube', 'silabas': ['nu', 'be']},
    {'palabra': 'taza', 'silabas': ['ta', 'za']},
    {'palabra': 'pila', 'silabas': ['pi', 'la']},
    {'palabra': 'moto', 'silabas': ['mo', 'to']},
    {'palabra': 'foca', 'silabas': ['fo', 'ca']}, // <-- Nueva palabra
  ];

  late List<Map<String, dynamic>> _niveles; // Lista de palabras para los 10 niveles
  int _nivelActual = 0;

  late Map<String, dynamic> _palabraActual;
  late List<String> _opcionesSilabas;
  List<String?> _respuesta = [null, null];
  String _mensaje = '';
  bool _bloqueado = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _audioInstruccion = AudioPlayer();
  Timer? _timerInstruccion;

  @override
  void initState() {
    super.initState();
    _iniciarMusicaFondo();
    _inicializarNiveles();
    _generarNuevaRonda();
  }

  void _inicializarNiveles() {
    // Selecciona 10 palabras aleatorias y diferentes
    _niveles = List<Map<String, dynamic>>.from(_palabras)..shuffle();
    _niveles = _niveles.take(10).toList();
    _nivelActual = 0;
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    _audioPlayer.dispose();
    _audioInstruccion.dispose();
    _timerInstruccion?.cancel();
    super.dispose();
  }

  Future<void> _iniciarMusicaFondo() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.play(AssetSource('sonidos/puzzlegame.mp3'));
    await _backgroundPlayer.setVolume(0.0);
  }

  void _repetirInstruccion(String ruta) async {
    await _audioInstruccion.stop();
    await _audioInstruccion.release();
    await _audioInstruccion.setVolume(3.0);
    await _audioInstruccion.play(AssetSource(ruta));
    _timerInstruccion?.cancel();
    _timerInstruccion = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _audioInstruccion.stop();
      await _audioInstruccion.release();
      await _audioInstruccion.setVolume(3.0);
      await _audioInstruccion.play(AssetSource(ruta));
    });
  }

  void _generarNuevaRonda() {
    if (_nivelActual >= 10) {
      _mostrarDialogoFinal();
      return;
    }
    final random = Random();
    _palabraActual = _niveles[_nivelActual];
    // Mezcla las sílabas correctas con sílabas incorrectas
    List<String> silabasIncorrectas = [];
    while (silabasIncorrectas.length < 2) {
      final otra = _palabras[random.nextInt(_palabras.length)];
      for (var s in otra['silabas']) {
        if (!(_palabraActual['silabas'] as List).contains(s) && !silabasIncorrectas.contains(s)) {
          silabasIncorrectas.add(s);
          if (silabasIncorrectas.length == 2) break;
        }
      }
    }
    _opcionesSilabas = [
      ..._palabraActual['silabas'],
      ...silabasIncorrectas
    ]..shuffle();

    setState(() {
      _respuesta = [null, null];
      _mensaje = '';
      _bloqueado = false;
    });

    _tocarPalabra();
  }

  Future<void> _tocarPalabra() async {
    for (var silaba in _palabraActual['silabas']) {
      await _tocarSonidoSilaba(silaba);
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  Future<void> _tocarSonidoSilaba(String silaba) async {
    final rutaSonido = 'silabas/$silaba.mp3';
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      await _audioPlayer.setVolume(1.0);
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource(rutaSonido));
    } catch (e) {
      print('Error al reproducir sonido: $e');
    }
  }

  Future<void> _tocarFeedback(String tipo) async {
    final rutaSonido = tipo == 'correcto'
        ? 'sonidos/correcto.mp3'
        : 'sonidos/incorrecto.mp3';
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      await _audioPlayer.setVolume(0.1);
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource(rutaSonido));
    } catch (e) {
      print('Error al reproducir feedback: $e');
    }
  }

  Future<void> _mostrarDialogoFinal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            '¡Felicidades!',
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: const Text(
          '¡Completaste los 10 niveles de sílabas!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.green.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop(); // Regresa a la pantalla anterior
            },
            child: const Text(
              'Salir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _verificarRespuesta() async {
    if (_respuesta.contains(null) || _bloqueado) return;
    bool acierto = _respuesta[0] == _palabraActual['silabas'][0] && _respuesta[1] == _palabraActual['silabas'][1];
    setState(() {
      _mensaje = acierto ? '¡Correcto!' : 'Incorrecto. Era ${_palabraActual['palabra']}';
      _bloqueado = true;
    });

    await _tocarFeedback(acierto ? 'correcto' : 'incorrecto');
    await _mostrarDialogoResultado(acierto);
  }

  Future<void> _mostrarDialogoResultado(bool acierto) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            acierto ? '¡Correcto!' : 'Incorrecto',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                acierto ? '¡Bien hecho!' : 'La palabra era:',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade900, width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _palabraActual['palabra'],
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _nivelActual++; // <--- ¡Aumenta el nivel aquí!
              });
              _generarNuevaRonda();
            },
            child: const Text(
              'Siguiente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progreso = (_nivelActual < 10) ? (_nivelActual / 10) : 1.0;

    // Ruta de la imagen de la palabra actual
    String? rutaImagen;
    if (_palabraActual != null && _palabraActual['palabra'] != null) {
      rutaImagen = 'assets/images/${_palabraActual['palabra']}.png';
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Fondolectura.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Barra de progreso tipo Duolingo
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
                                  width: (MediaQuery.of(context).size.width - 60) * progreso,
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
                      const SizedBox(height: 20),
                      if (rutaImagen != null)
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              rutaImagen,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(
                                width: 120,
                                height: 120,
                                child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text(
                        'Arrastra las sílabas para formar la palabra',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSilabaTarget(0),
                          const SizedBox(width: 10),
                          _buildSilabaTarget(1),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.deepOrange.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () async {
                          await _tocarPalabra();
                        },
                        icon: const Icon(Icons.volume_up, size: 28),
                        label: const Text(
                          'Escuchar palabra',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children: _opcionesSilabas.map((silaba) {
                          return GestureDetector(
                            onTap: () async {
                              await _tocarSonidoSilaba(silaba);
                            },
                            child: Draggable<String>(
                              data: silaba,
                              feedback: _buildSilabaCard(silaba, 80, opacity: 0.7),
                              childWhenDragging: _buildSilabaCard(silaba, 80, opacity: 0.3),
                              child: _buildSilabaCard(silaba, 80),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.green.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: (!_bloqueado && !_respuesta.contains(null)) ? _verificarRespuesta : null,
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _mensaje,
                        style: TextStyle(
                          fontSize: 22,
                          color: _mensaje == '¡Correcto!' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilabaTarget(int index) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: candidateData.isNotEmpty
                  ? Colors.orange
                  : (_respuesta[index] != null ? Colors.blue : Colors.grey),
              width: 3,
            ),
          ),
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            child: Text(
              _respuesta[index] ?? '?',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      onAccept: (data) {
        setState(() {
          _respuesta[index] = data;
        });
        _verificarRespuesta();
      },
      onWillAccept: (data) => !_bloqueado && !_respuesta.contains(data),
    );
  }

  Widget _buildSilabaCard(String silaba, double size, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Text(
            silaba,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}