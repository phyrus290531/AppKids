import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const VocalesJuegoApp());
}

class VocalesJuegoApp extends StatelessWidget {
  const VocalesJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Vocales',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const VocalesGame(),
    );
  }
}


class _OpcionSeleccionada {
  String letra;
  String rutaImagen;
  _OpcionSeleccionada({required this.letra, required this.rutaImagen});
}

class VocalesGame extends StatefulWidget {
  const VocalesGame({super.key});

  @override
  State<VocalesGame> createState() => _VocalesGameState();
}

class _VocalesGameState extends State<VocalesGame> {
  final List<String> _vocales = ['A', 'E', 'I', 'O', 'U'];

  late List<String> _nivelesVocales; // Lista de vocales para los 10 niveles
  int _nivelActual = 0;

  late String _letraActual;
  late List<String> _opciones;
  String _mensaje = '';
  bool _bloqueado = false;
  _OpcionSeleccionada? _seleccionada;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  Map<String, String> _rutasCache = {};

  bool _modoArrastrar = false;
  String? _letraArrastrada;
  Timer? _timerInstruccion;
  final AudioPlayer _audioInstruccion = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _iniciarMusicaFondo();
    _inicializarNiveles();
    _generarNuevaRonda();
  }

  void _inicializarNiveles() {
    // 5 niveles de seleccionar y 5 de arrastrar, cada vocal una vez por modo
    List<String> vocalesSeleccion = List.from(_vocales)..shuffle();
    List<String> vocalesArrastrar = List.from(_vocales)..shuffle();
    _nivelesVocales = [];
    for (int i = 0; i < 5; i++) {
      _nivelesVocales.add(vocalesSeleccion[i]);
      _nivelesVocales.add(vocalesArrastrar[i]);
    }
    // Alternar modos: primero seleccionar, luego arrastrar, etc.
    // Si quieres primero 5 de un modo y luego 5 del otro, cambia el orden aquí.
    _nivelActual = 0;
    _modoArrastrar = false;
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    _audioPlayer.dispose();
    _audioInstruccion.dispose();
    _timerInstruccion?.cancel();
    super.dispose();
  }

  void _cambiarModoYRepetirInstruccion() {
    _timerInstruccion?.cancel();
    String audio = _modoArrastrar
        ? 'sonidos/Arrastra_la_vocal.mp3'
        : 'sonidos/Que_vocal_es_esta.mp3';
    _repetirInstruccion(audio);
  }

void _repetirInstruccion(String ruta) async {
  // Reproduce inmediatamente
  await _audioInstruccion.stop();
  await _audioInstruccion.release();
  await _audioInstruccion.setVolume(3.0); // Volumen máximo
  await _audioInstruccion.play(AssetSource(ruta));
  // Programa repetición cada 6 segundos
  _timerInstruccion?.cancel();
  _timerInstruccion = Timer.periodic(const Duration(seconds: 6), (_) async {
    await _audioInstruccion.stop();
    await _audioInstruccion.release();
    await _audioInstruccion.setVolume(3.0); // Volumen máximo
    await _audioInstruccion.play(AssetSource(ruta));
  });
}
  Future<void> _iniciarMusicaFondo() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.play(AssetSource('sonidos/puzzlegame.mp3'));
    await _backgroundPlayer.setVolume(0.0); // Volumen más bajo
  }

  void _generarNuevaRonda() async {
    if (_nivelActual >= 10) {
      await _mostrarDialogoFinal();
      return;
    }

    _letraActual = _nivelesVocales[_nivelActual];
    // Alternar modo cada nivel
    _modoArrastrar = _nivelActual % 2 == 1;

    List<String> opcionesIncorrectas = List.from(_vocales)..remove(_letraActual);
    opcionesIncorrectas.shuffle();
    _opciones = [_letraActual, opcionesIncorrectas[0], opcionesIncorrectas[1], opcionesIncorrectas[2]];
    _opciones.shuffle();

    setState(() {
      _mensaje = '';
      _seleccionada = null;
      _bloqueado = false;
      _letraArrastrada = null;
    });

    _cambiarModoYRepetirInstruccion();

    await _tocarSonido(_letraActual);
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
          '¡Completaste los 10 niveles de las vocales!',
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
    await _audioPlayer.setVolume(0.1); // Volumen bajo (ajusta el valor si quieres)
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
    _nivelActual++;
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

  void _verificarArrastre() async {
    if (_letraArrastrada == null || _bloqueado) return;

    bool acerto = _letraArrastrada == _letraActual;
    setState(() {
      _mensaje = acerto ? '¡Correcto!' : 'Incorrecto. Era $_letraActual';
      _bloqueado = true;
    });

    await _tocarFeedback(acerto ? 'correcto' : 'incorrecto');
    await _mostrarDialogoResultado(acerto);
  }

  @override
  Widget build(BuildContext context) {
    double progreso = (_nivelActual < 10) ? (_nivelActual / 10) : 1.0;

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
                      Text(
                        _modoArrastrar ? 'Arrastra la vocal que escuchaste:' : '¿Qué vocal es esta?',
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _modoArrastrar
                          ? Column(
                              children: [
                                DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) {
                                    if (_letraArrastrada != null && _rutasCache.containsKey(_letraArrastrada)) {
                                      return Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            _rutasCache[_letraArrastrada]!,
                                            width: 150,
                                            height: 150,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.blue, width: 3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '?',
                                            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      _letraArrastrada = data;
                                    });
                                    _verificarArrastre();
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
                                    'Escuchar vocal',
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
                            )
                          : FutureBuilder<String>(
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
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children: _opciones.map((opcion) {
                          return FutureBuilder<String>(
                            future: _obtenerRutaImagen(opcion),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return _modoArrastrar
                                    ? Draggable<String>(
                                        data: opcion,
                                        feedback: _buildVocalImagen(snapshot.data!, 80),
                                        childWhenDragging: _buildVocalImagen(snapshot.data!, 80, opacity: 0.3),
                                        child: _buildVocalImagen(snapshot.data!, 80),
                                      )
                                    : GestureDetector(
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
                      if (!_modoArrastrar)
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
                      if (!_modoArrastrar)
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

  Widget _buildVocalImagen(String ruta, double size, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(ruta, width: size, height: size),
      ),
    );
  }
}
