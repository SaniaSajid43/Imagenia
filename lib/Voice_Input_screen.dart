import 'package:flutter/material.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({Key? key}) : super(key: key);

  @override
  _VoiceInputScreenState createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  String description = '';
  List<String> generatedImages = []; // Placeholder list for generated images

  void onVoiceInput() async {
    // This is where you would trigger the voice input functionality
    // For now, we'll simulate it with a placeholder text
    setState(() {
      description = "Sample voice input description"; // replace with actual voice-to-text
      generateImages();
    });
  }

  void generateImages() {
    // Simulate generated images; replace with actual image generation
    setState(() {
      generatedImages = [
        'assets/images/sample1.jpg',
        'assets/images/sample2.jpg',
        'assets/images/sample3.jpg'
      ];
    });
  }

  void _selectImage(int index) {
    // Handle image selection
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(generatedImages[index]), // Display selected image
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input ', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24293E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back when back button is pressed
          },
        ),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Description',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic, color: Colors.white),
                  label: const Text("Record Voice", style: TextStyle(color: Colors.white)),
                  onPressed: onVoiceInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description.isEmpty ? 'No description yet.' : description,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Generated Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: generatedImages.isEmpty
                      ? const Center(
                    child: Text(
                      'No images generated.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: generatedImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _selectImage(index), // Handle image tap
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              generatedImages[index],
                              fit: BoxFit.cover,
                            ),
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