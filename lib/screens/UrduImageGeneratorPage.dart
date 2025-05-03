import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UrduImageGeneratorPage extends StatefulWidget {
  @override
  _UrduImageGeneratorPageState createState() => _UrduImageGeneratorPageState();
}

class _UrduImageGeneratorPageState extends State<UrduImageGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isUrdu = true;
  String _generationType = 'image'; // 'image' or 'sketch'
  late stt.SpeechToText _speech;
  int _selectedImageCount = 1;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> generateImage(String description) async {
    setState(() {
      _isLoading = true;
      _imageUrls = [];
    });

    final String url = _generationType == 'sketch'
        ? "https://70c7-34-87-164-68.ngrok-free.app/generate_sketch"
        : "https://70c7-34-87-164-68.ngrok-free.app/generate";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': description,
          'num_images': _selectedImageCount,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<String> urls = List<String>.from(responseData['image_urls']);

        setState(() {
          _imageUrls = urls;
        });

        // 🔥 Save image URLs to Firestore
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final firestore = FirebaseFirestore.instance;
          for (String url in urls) {
            await firestore
                .collection('users')
                .doc(uid)
                .collection('generated_images')
                .add({
              'image_url': url,
              'timestamp': FieldValue.serverTimestamp(),
              'type': _generationType,
            });
          }
        } else {
          print('User not logged in. Cannot save to Firestore.');
        }
      } else {
        print('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          localeId: _isUrdu ? 'ur-PK' : 'en-US',
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2430),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Multi Language', style: TextStyle(color: Colors.white)),
        actions: [
          Row(
            children: [
              const Text('EN', style: TextStyle(color: Colors.white)),
              Switch(
                value: _isUrdu,
                onChanged: (value) => setState(() => _isUrdu = value),
                activeColor: Colors.yellow,
              ),
              const Text('UR', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 12),
            ],
          ),
        ],
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Description (in Urdu or English)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: _isUrdu ? 'اردو میں تفصیل لکھیں...' : 'Write your description...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                        ),
                      ),
                      IconButton(
                        tooltip: _isListening ? 'Listening...' : 'Voice Input',
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.blueAccent,
                        ),
                        onPressed: _listen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() => _generationType = 'image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _generationType == 'image' ? const Color(0xFFBFD9F2) : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Image'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => setState(() => _generationType = 'sketch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _generationType == 'sketch' ? const Color(0xFFBFD9F2) : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Sketch'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Select:', style: TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: DropdownButton<int>(
                            value: _selectedImageCount,
                            items: List.generate(5, (index) => index + 1)
                                .map((count) =>
                                    DropdownMenuItem<int>(value: count, child: Text(count.toString())))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedImageCount = value;
                                });
                              }
                            },
                            underline: Container(),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String description = _controller.text.trim();
                      if (description.isNotEmpty) {
                        generateImage(description);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a description first.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFD9F2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Generate Image',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Generated Output',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  child: _imageUrls.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueAccent, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "${_imageUrls[index]}?v=${DateTime.now().millisecondsSinceEpoch}",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No image generated yet.', style: TextStyle(color: Colors.white)),
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
