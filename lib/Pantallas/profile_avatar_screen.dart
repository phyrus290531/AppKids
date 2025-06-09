import 'package:flutter/material.dart';

class ProfileAvatarScreen extends StatefulWidget {
  @override
  State<ProfileAvatarScreen> createState() => _ProfileAvatarScreenState();
}

class _ProfileAvatarScreenState extends State<ProfileAvatarScreen> {
  // Lista de rutas de imágenes de avatares (actualizada)
  final List<String> avatars = [
    'assets/images/Personaje_1.jpg',
    'assets/images/Personaje_2.jpg',
    'assets/images/Personaje_3.jpg',
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Recibe nombre y edad desde arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String nombre = args['name'] ?? '';
    final int edad = args['age'] ?? 0;

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
            SizedBox(height: 16),
            Text(
              "Elige un personaje para $nombre",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: avatars.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedIndex == index ? Colors.blue : Colors.transparent,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue.shade50,
                            backgroundImage: AssetImage(avatars[index]),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Puedes poner nombres de personajes si quieres
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedIndex != null
                  ? () {
                      // Aquí puedes guardar el perfil completo (nombre, edad, avatar)
                      // y regresar al selector de perfiles o a la pantalla principal
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/profiles',
                        (route) => false,
                        arguments: {
                          'name': nombre,
                          'age': edad,
                          'avatar': avatars[selectedIndex!],
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