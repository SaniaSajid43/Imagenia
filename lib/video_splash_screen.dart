import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart'; // Import your login screen

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({Key? key}) : super(key: key);

  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller
    _controller = VideoPlayerController.asset('assets/videos/logo.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown before navigating
        if (mounted) {
          setState(() {}); // Refresh the UI once video is initialized
          _controller.play();
          _controller.setLooping(false);

          // Navigate to the login screen after 5 seconds, if video is loaded
          Future.delayed(const Duration(seconds: 1), () {
            if (_controller.value.isInitialized) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
        }
      }).catchError((error) {
        // Handle initialization errors
        print("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Optional background color
      body: Center(
        child: _controller.value.isInitialized
            ? Container(
          width: 300, // Set your desired width
          height: 300, // Set your desired height
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        )
            : const CircularProgressIndicator(), // Show loading spinner while initializing
      ),
    );
  }
}
