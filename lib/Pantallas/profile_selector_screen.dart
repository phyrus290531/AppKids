import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';

class ProfileSelectorScreen extends StatefulWidget {
  @override
  State<ProfileSelectorScreen> createState() => _ProfileSelectorScreenState();
}

class _ProfileSelectorScreenState extends State<ProfileSelectorScreen> {
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesString = prefs.getString('profiles');
    if (profilesString != null) {
      final List decoded = jsonDecode(profilesString);
      setState(() {
        profiles = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _addProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    // Evita duplicados por nombre y avatar
    if (!profiles.any((p) => p['name'] == profile['name'] && p['avatar'] == profile['avatar'])) {
      profiles.add(profile);
      await prefs.setString('profiles', jsonEncode(profiles));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Solo agrega el perfil si viene de la pantalla de avatar y no se ha agregado aún
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('name')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addProfile(args);
        // Limpia argumentos para evitar duplicados
        Navigator.pushReplacementNamed(context, '/profiles');
      });
      return SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("¿Quién aprenderá hoy?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar todos',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('profiles');
              setState(() {
                profiles.clear();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          children: [
            ...profiles.map((profile) => GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              onLongPress: () async {
                // Elimina este perfil individualmente
                final prefs = await SharedPreferences.getInstance();
                profiles.remove(profile);
                await prefs.setString('profiles', jsonEncode(profiles));
                setState(() {});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(profile['avatar']),
                    backgroundColor: Colors.blue.shade100,
                  ),
                  SizedBox(height: 8),
                  Text(profile['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            // Botón "Add a child"
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile_name');
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.add, size: 48, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Add a child', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}