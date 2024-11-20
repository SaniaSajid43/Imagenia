import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF24293E),
              ),
              child: const Text(
                'Dashboard Functions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Text to Images'),
              onTap: () {
                Navigator.pushNamed(context, '/text2img');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text('Reconstruct Images'),
              onTap: () {
                Navigator.pushNamed(context, '/reconstructImages');
              },
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Recent Images'),
              onTap: () {
                Navigator.pushNamed(context, '/memoryBasedImageGen');
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
          // Background image covering the full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // Replace with your background image path
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
                          text: 'Reconstruct Images',
                          onPressed: () {
                            Navigator.pushNamed(context, '/reconstructImages');
                          },
                        ),
                        const SizedBox(height: 15),
                        buildDashboardCard(
                          icon: Icons.memory,
                          text: 'Recent Images',
                          onPressed: () {
                            Navigator.pushNamed(context, '/memoryBasedImageGen');
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
      color: Colors.white.withOpacity(0.9), // Light white background for the card
      elevation: 3, // Adjusted elevation for subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 80, // Increased height for better visibility
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button color to match the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0, // No shadow on button
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 30), // Icon color matching your theme
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A), // Text color matching your theme
                    fontSize: 20, // Increased font size for better readability
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
