import 'package:flutter/material.dart';

class Text2Img extends StatefulWidget {
  const Text2Img({Key? key}) : super(key: key);

  @override
  _Text2ImgState createState() => _Text2ImgState();
}

class _Text2ImgState extends State<Text2Img> {
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _generatedImages = []; // List to store generated image paths (placeholders)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Text to Image Generation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF24293E),
      ),
      body: Stack(
        children: [
          // // Background image
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
                const Text(
                  'Enter Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Change background color to white
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Type a description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none, // Remove border side for seamless look
                      ),
                      filled: true,
                      fillColor: Colors.white, // Ensure fill color is white
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _generateImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87CEEB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate Images',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Generated Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: _generatedImages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Change color of image box to white
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage(_generatedImages[index]), // Placeholder image path
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

  // Placeholder function to simulate image generation
  void _generateImages() {
    // Add mock images as placeholders
    setState(() {
      _generatedImages = [
        'assets/images/sample1.jpg',
        'assets/images/sample2.jpg',
        'assets/images/sample3.jpg',
        'assets/images/sample4.jpg',
      ];
    });
  }

  // Function to handle image selection
  void _selectImage(int index) {
    // Display selected image in the area or take any other action
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(_generatedImages[index]), // Display selected image
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Code for setting this image as the chosen one
                },
                child: const Text('Select this Image'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
