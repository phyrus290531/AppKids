import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const AbecedarioJuegoApp());
}

class AbecedarioJuegoApp extends StatelessWidget {
  const AbecedarioJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adivina la letra',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AbecedarioGame(),
    );
  }
}

class _OpcionSeleccionada {
  String letra;
  String rutaImagen;
  _OpcionSeleccionada({required this.letra, required this.rutaImagen});
}

class AbecedarioGame extends StatefulWidget {
  const AbecedarioGame({super.key});

  @override
  State<AbecedarioGame> createState() => _AbecedarioGameState();
}

class _AbecedarioGameState extends State<AbecedarioGame> {
  final List<String> _abecedario = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  late String _letraActual;
  late List<String> _opciones;
  String _mensaje = '';
  bool _bloqueado = false;
  _OpcionSeleccionada? _seleccionada;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, String> _rutasCache = {};

  int _nivelActual = 0;
  final int _maxNiveles = 10;
  late List<String> _niveles; // Letras para los 10 niveles

  @override
  void initState() {
    super.initState();
    _niveles = List<String>.from(_abecedario)..shuffle();
    _niveles = _niveles.take(_maxNiveles).toList();
    _nivelActual = 0;
    _generarNuevaRonda();
  }

  void _generarNuevaRonda() async {
    if (_nivelActual >= _maxNiveles) {
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
            '¡Completaste los 10 niveles!',
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
                Navigator.of(context).maybePop();
              },
              child: const Text(
                'Salir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final random = Random();
    _letraActual = _niveles[_nivelActual];

    List<String> opcionesIncorrectas = List.from(_abecedario)..remove(_letraActual);
    opcionesIncorrectas.shuffle();
    _opciones = [_letraActual, opcionesIncorrectas[0], opcionesIncorrectas[1]];
    _opciones.shuffle();

    setState(() {
      _mensaje = '';
      _seleccionada = null;
      _bloqueado = false;
    });

    await _tocarSonido(_letraActual);
  }

  Future<void> _tocarSonido(String letra) async {
    final rutaSonido = 'sonidos/alphabet-${letra.toLowerCase()}.mp3';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
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
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource(rutaSonido));
    } catch (e) {
      print('Error al reproducir feedback: $e');
    }
  }

  Future<String> _obtenerRutaImagen(String letra) async {
    if (_rutasCache.containsKey(letra)) return _rutasCache[letra]!;

    String rutaJpg = 'assets/letras/$letra.jpg';
    String rutaJpeg = 'assets/letras/$letra.jpeg';

    try {
      await rootBundle.load(rutaJpg);
      _rutasCache[letra] = rutaJpg;
      return rutaJpg;
    } catch (_) {
      await rootBundle.load(rutaJpeg);
      _rutasCache[letra] = rutaJpeg;
      return rutaJpeg;
    }
  }

  Future<void> _mostrarDialogoResultado(bool acierto) async {
    final rutaImagen = await _obtenerRutaImagen(_letraActual);

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
                acierto ? '¡Bien hecho!' : 'Era:',
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
                child: Image.asset(rutaImagen, width: 100, height: 100),
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
                _nivelActual++;
              });
              _generarNuevaRonda();
              await _tocarSonido(_letraActual);
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

  void _verificarOpcion() async {
    if (_seleccionada == null || _bloqueado) return;

    bool acerto = _seleccionada!.letra == _letraActual;
    setState(() {
      _mensaje = acerto ? '¡Correcto!' : 'Incorrecto. Era $_letraActual';
      _bloqueado = true;
    });

    await _tocarFeedback(acerto ? 'correcto' : 'incorrecto');
    await _mostrarDialogoResultado(acerto);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progreso = (_nivelActual < _maxNiveles) ? (_nivelActual / _maxNiveles) : 1.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fondo/fondo1.jpg',
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
                      // Barra de progreso y botón de regreso
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
                      const Text(
                        '¿Qué letra es esta?',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: _obtenerRutaImagen(_letraActual),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(snapshot.data!, width: 150, height: 150),
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
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
                          await _tocarSonido(_letraActual);
                        },
                        icon: const Icon(Icons.volume_up, size: 28),
                        label: const Text(
                          'Escuchar letra',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Elige la letra correcta:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: _opciones.map((opcion) {
                          return FutureBuilder<String>(
                            future: _obtenerRutaImagen(opcion),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return GestureDetector(
                                  onTap: _bloqueado
                                      ? null
                                      : () async {
                                          await _tocarSonido(opcion);
                                          setState(() {
                                            _seleccionada = _OpcionSeleccionada(
                                              letra: opcion,
                                              rutaImagen: snapshot.data!,
                                            );
                                          });
                                        },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: (_seleccionada?.letra == opcion)
                                              ? Colors.blue
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: Image.asset(snapshot.data!, width: 100, height: 100),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
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
                        onPressed: (!_bloqueado && _seleccionada != null) ? _verificarOpcion : null,
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
}
