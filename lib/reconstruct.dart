import 'package:flutter/material.dart';

class ReconstructImagesScreen extends StatelessWidget {
  const ReconstructImagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconstruct Images'),
        backgroundColor: const Color(0xFF24293E),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Upload a Damaged Image',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      'Display Damaged Image Here',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Future implementation of image upload
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text(
                    'Upload Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Reconstructed Image',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      'Display Reconstructed Image Here',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Future implementation of image reconstruction
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text(
                    'Reconstruct Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
