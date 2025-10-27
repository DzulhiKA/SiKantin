import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          'Ini adalah halaman profil pengguna.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
  