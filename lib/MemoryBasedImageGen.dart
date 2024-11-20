import 'package:flutter/material.dart';

class MemoryBasedImageGen extends StatefulWidget {
  const MemoryBasedImageGen({Key? key}) : super(key: key);

  @override
  _MemoryBasedImageGenState createState() => _MemoryBasedImageGenState();
}

class _MemoryBasedImageGenState extends State<MemoryBasedImageGen> {
  final TextEditingController _descriptionController = TextEditingController();

  // Mock data for previously generated images
  final Map<String, List<String>> _previousImages = {
    'sunset': [
      'assets/images/sunset1.jpg',
      'assets/images/sunset2.jpg',
      'assets/images/sunset3.jpg',
    ],
    'mountain': [
      'assets/images/mountain1.jpg',
      'assets/images/mountain2.jpg',
    ],
    // Add more descriptions and their corresponding image paths
  };

  List<String> _displayedImages = [];

  void _searchImages() {
    final description = _descriptionController.text.toLowerCase();
    setState(() {
      _displayedImages = _previousImages[description] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Images'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Enter Image Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _searchImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Search Images'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Previously Generated Images',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _displayedImages.isEmpty
                      ? const Center(
                    child: Text(
                      'No images found.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _displayedImages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.asset(
                            _displayedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
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
