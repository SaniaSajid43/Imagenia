import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Text2Sketch extends StatefulWidget {
  const Text2Sketch({super.key});

  @override
  _Text2SketchState createState() => _Text2SketchState();
}

class _Text2SketchState extends State<Text2Sketch> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _generatedSketches = [];
  final Set<int> _selectedIndexes = {};
  bool _isLoading = false;
  int _selectedImageCount = 1;

  Future<void> _generateSketch() async {
    final prompt = _descriptionController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedSketches.clear();
      _selectedIndexes.clear();
    });

    try {
      final response = await http.post(
        Uri.parse("https://584c-34-16-142-221.ngrok-free.app/generate_sketch"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": prompt,
          "num_images": _selectedImageCount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrls = List<String>.from(data["image_urls"] ?? []);
        if (imageUrls.isNotEmpty) {
          setState(() => _generatedSketches.addAll(imageUrls));
          await _saveSketchesToFirestore(imageUrls);
        }
      } else {
        debugPrint("Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Connection error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSketchesToFirestore(List<String> urls) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('generated_images');

    for (final url in urls) {
      await ref.add({
        'image_url': url,
        'type': 'sketch',
        'prompt': _descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _saveImageToGallery(String imageUrl) async {
    try {
      final permissionStatus = Platform.isIOS
          ? await Permission.photos.request()
          : await Permission.storage.request();

      if (permissionStatus.isGranted) {
        final response = await http.get(Uri.parse(imageUrl));
        final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.bodyBytes));
        final success = result['isSuccess'] == true;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? "Image saved to gallery" : "Failed to save image"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied")),
        );
      }
    } catch (e) {
      debugPrint("Save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Sketch', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24293E),
        iconTheme: const IconThemeData(color: Colors.white),
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
                const Text('Describe the sketch',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Write sketch description here ..',
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Number of sketches:", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButton<int>(
                        value: _selectedImageCount,
                        items: List.generate(5, (i) => i + 1)
                            .map((count) => DropdownMenuItem(value: count, child: Text(count.toString())))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedImageCount = value ?? 1),
                        underline: Container(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateSketch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87CEEB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Generate Sketch', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Generated Sketches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  child: _generatedSketches.isEmpty
                      ? const Center(
                          child: Text('No sketches generated yet.', style: TextStyle(color: Colors.white)),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                itemCount: _generatedSketches.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  final url =
                                      "${_generatedSketches[index]}?v=${DateTime.now().millisecondsSinceEpoch}";
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blueAccent, width: 2),
                                          image: DecorationImage(
                                            image: NetworkImage(url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Checkbox(
                                          value: _selectedIndexes.contains(index),
                                          onChanged: (checked) {
                                            setState(() {
                                              if (checked == true) {
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
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_selectedIndexes.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please select at least one image")),
                                  );
                                  return;
                                }
                                for (var i in _selectedIndexes) {
                                  await _saveImageToGallery(_generatedSketches[i]);
                                }
                              },
                              icon: const Icon(Icons.download),
                              label: const Text("Save Selected Images"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
