import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Voice2Img extends StatefulWidget {
  const Voice2Img({super.key});

  @override
  _Voice2ImgState createState() => _Voice2ImgState();
}

class _Voice2ImgState extends State<Voice2Img> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _generatedImages = [];
  bool _isLoading = false;
  bool _isListening = false;
  late stt.SpeechToText _speech;
  String _selectedLanguage = 'ur_PK';
  String _generationType = 'image';
  int _numImages = 1;

  final Map<String, String> _languageOptions = {
    'اردو': 'ur_PK',
    'English': 'en_US',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Firestore mein images save karne ka function
  Future<void> _saveImagesToFirestore(List<String> imageUrls) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        CollectionReference userImages = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('generated_images');

        for (String url in imageUrls) {
          await userImages.add({
            'image_url': url,
            'timestamp': FieldValue.serverTimestamp(),
            'type': _generationType,
          });
        }

        print("Images saved to Firestore successfully.");
      }
    } catch (e) {
      print("Error saving images to Firestore: $e");
    }
  }

  // Image generation ka function
  Future<void> _generateImages(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final String url = _generationType == 'sketch'
        ? "https://b86f-34-125-68-39.ngrok-free.app/generate_sketch"
        : "https://b86f-34-125-68-39.ngrok-free.app/generate";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": prompt,
          "num_images": _numImages,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["image_urls"] != null) {
          List<dynamic> imageUrls = responseData["image_urls"];
          setState(() {
            _generatedImages.clear();
            _generatedImages.addAll(imageUrls.cast<String>());
          });

          // Images ko Firestore mein save karein
          await _saveImagesToFirestore(_generatedImages);
        } else {
          print("No image_urls found.");
        }
      } else {
        print("Error from server: ${response.body}");
      }
    } catch (e) {
      print("Error during request: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Listening start karne ka function
  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (e) => print("Speech error: $e"),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        },
        localeId: _selectedLanguage,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
      );
    } else {
      print("Speech recognition not available.");
    }
  }

  // Listening stop karne ka function
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    _generateImages(_descriptionController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice to Image/Sketch', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24293E),
        iconTheme: const IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Select Language:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      onChanged: (String? newLang) {
                        if (newLang != null) {
                          setState(() => _selectedLanguage = newLang);
                        }
                      },
                      items: _languageOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(value: entry.value, child: Text(entry.key));
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Select Type:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _generationType = 'image';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _generationType == 'image' ? Color(0xFFBFD9F2) : Colors.grey,
                      ),
                      child: const Text('Image'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _generationType = 'sketch';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _generationType == 'sketch' ? Color(0xFFBFD9F2) : Colors.grey,
                      ),
                      child: const Text('Sketch'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Speak your description here...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Select Number of Images:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: _numImages,
                        dropdownColor: Colors.white,
                        underline: SizedBox(),
                        iconEnabledColor: Colors.black,
                        onChanged: (int? newValue) {
                          setState(() {
                            _numImages = newValue!;
                          });
                        },
                        items: [1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(value: value, child: Text('$value'));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _generateImages(_descriptionController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBFD9F2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Generate'),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.black54,
                        size: 30,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Generated Output:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _generatedImages.isEmpty
                      ? const Center(
                          child: Text(
                            'No output generated yet.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : GridView.builder(
                          itemCount: _generatedImages.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.black.withOpacity(0.3),
                              child: Image.network(
                                _generatedImages[index],
                                fit: BoxFit.cover,
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
