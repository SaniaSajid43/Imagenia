import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Text2Img extends StatefulWidget {
  const Text2Img({super.key});

  @override
  _Text2ImgState createState() => _Text2ImgState();
}

class _Text2ImgState extends State<Text2Img> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _generatedImages = [];
  final Set<int> _selectedIndexes = {};
  bool _isLoading = false;
  int _numImages = 1;

  final String flaskEndpoint = "https://584c-34-16-142-221.ngrok-free.app/generate";

  Future<void> _generateImages() async {
    String prompt = _descriptionController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _selectedIndexes.clear(); // Clear selections on new generation
    });

    try {
      final response = await http.post(
        Uri.parse(flaskEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": prompt,
          "num_images": _numImages,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null && responseData["image_urls"] != null) {
          List<String> imageUrls = List<String>.from(responseData["image_urls"]);
          setState(() {
            _generatedImages.clear();
            _generatedImages.addAll(imageUrls);
          });
          await _saveImagesToFirestore(imageUrls);
        } else {
          _showMessage("Unexpected response format.");
        }
      } else {
        _showMessage("Error from server: ${response.body}");
      }
    } catch (e) {
      _showMessage("Connection error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveImagesToFirestore(List<String> imageUrls) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference userImages = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('generated_images');

        for (String url in imageUrls) {
          await userImages.add({
            'image_url': url,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      _showMessage("Failed to save images: $e");
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      var storageStatus = await Permission.storage.request();
      var mediaStatus = await Permission.photos.request(); // For Android 13+

      if (!storageStatus.isGranted && !mediaStatus.isGranted) {
        _showMessage("Storage permission denied");
        return;
      }

      var response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = Uint8List.fromList(response.bodyBytes);

      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: "imagenia_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess'] == true || result['filePath'] != null) {
        _showMessage("Image saved to gallery!");
      } else {
        _showMessage("Failed to save image.");
      }
    } catch (e) {
      _showMessage("Download failed: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Text to Image Generation', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24293E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Type a description...',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      filled: true,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Number of Images:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButton<int>(
                        value: _numImages,
                        onChanged: (newValue) => setState(() => _numImages = newValue!),
                        items: [1, 2, 3, 4]
                            .map((val) => DropdownMenuItem(value: val, child: Text('$val')))
                            .toList(),
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87CEEB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Generate Images',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Generated Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  child: _generatedImages.isEmpty
                      ? const Center(
                          child: Text('No images generated yet.', style: TextStyle(color: Colors.white)),
                        )
                      : GridView.builder(
                          itemCount: _generatedImages.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            final url =
                                "${_generatedImages[index]}?v=${DateTime.now().millisecondsSinceEpoch}";
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedIndexes.contains(index)
                                          ? Colors.green
                                          : Colors.blueAccent,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Checkbox(
                                    value: _selectedIndexes.contains(index),
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedIndexes.add(index);
                                        } else {
                                          _selectedIndexes.remove(index);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _selectedIndexes.isEmpty
                        ? null
                        : () async {
                            for (int index in _selectedIndexes) {
                              await _downloadImage(_generatedImages[index]);
                            }
                            _showMessage("${_selectedIndexes.length} image(s) saved to gallery!");
                            setState(() {
                              _selectedIndexes.clear();
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Selected Images',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
