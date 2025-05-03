import 'package:flutter/material.dart';
 import 'recent_images_screen.dart'; 
// ← import your history screen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF24293E),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/userProfile');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF24293E),
              ),
              child: Text(
                'Dashboard Functions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Text to Images'),
              onTap: () {
                Navigator.pushNamed(context, '/text2img');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text('Sketch Generation'),
              onTap: () {
                Navigator.pushNamed(context, '/sketch');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),  // ← new
              title: const Text('My History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecentImagesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Multi-Language'),
              onTap: () {
                Navigator.pushNamed(context, '/reconstructImages');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Voice Input'),
              onTap: () {
                Navigator.pushNamed(context, '/voiceInput');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Mode'),
              onTap: () {
                // Toggle mode functionality here
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        buildDashboardCard(
                          icon: Icons.description,
                          text: 'Text to Images',
                          onPressed: () {
                            Navigator.pushNamed(context, '/text2img');
                          },
                        ),
                        const SizedBox(height: 15),
                        buildDashboardCard(
                          icon: Icons.image_search,
                          text: 'Text to Sketch',
                          onPressed: () {
                            Navigator.pushNamed(context, '/sketch');
                          },
                        ),
                        const SizedBox(height: 15),
                        buildDashboardCard(
                          icon: Icons.history,  // ← new
                          text: 'My History',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RecentImagesScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        buildDashboardCard(
                          icon: Icons.language,
                          text: 'Languages',
                          onPressed: () {
                            Navigator.pushNamed(context, '/reconstructImages');
                          },
                        ),
                        const SizedBox(height: 15),
                        buildDashboardCard(
                          icon: Icons.mic,
                          text: 'Voice Input',
                          onPressed: () {
                            Navigator.pushNamed(context, '/voiceInput');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardCard({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 30),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
