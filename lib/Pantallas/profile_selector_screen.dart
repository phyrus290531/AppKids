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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 5 : screenWidth > 600 ? 4 : 2;
    final cardColor = Colors.blue.shade700; // Mismo tono que splashScreen

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('name')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addProfile(args);
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
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.8,
          children: [
            ...profiles.map((profile) => GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              onLongPress: () async {
                final prefs = await SharedPreferences.getInstance();
                profiles.remove(profile);
                await prefs.setString('profiles', jsonEncode(profiles));
                setState(() {});
              },
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(profile['avatar']),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      SizedBox(height: 12),
                      Text(
                        profile['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            )),
            // Botón "Add a child"
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile_name');
              },
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, size: 48, color: Colors.blue.shade700),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Add a child',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}