import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'available_gigs_tab.dart';
import 'my_gigs_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flovi Driver'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'My Gigs'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () => supabase.auth.signOut(),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            AvailableGigsTab(),
            MyGigsTab(),
          ],
        ),
      ),
    );
  }
}
