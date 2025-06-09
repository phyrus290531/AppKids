import 'package:flutter/material.dart';

class ProfileAgeScreen extends StatefulWidget {
  @override
  State<ProfileAgeScreen> createState() => _ProfileAgeScreenState();
}

class _ProfileAgeScreenState extends State<ProfileAgeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _enabled = _controller.text.trim().isNotEmpty && int.tryParse(_controller.text.trim()) != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recibe el nombre desde arguments
    final String nombre = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Image.asset('assets/icons/Logo.png', height: 120),
            SizedBox(height: 32),
            Text(
              "¿Cuántos años tiene $nombre?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Personalizaremos la experiencia para esta edad.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Edad",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _enabled
                  ? () {
                      // Pasa nombre y edad a la siguiente pantalla (avatar)
                      Navigator.pushNamed(
                        context,
                        '/profile_avatar',
                        arguments: {
                          'name': nombre,
                          'age': int.tryParse(_controller.text.trim()) ?? 0,
                        },
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("CONTINUAR", style: TextStyle(fontSize: 18, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}