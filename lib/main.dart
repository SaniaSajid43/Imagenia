import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/Text2Sketch.dart';
import 'screens/Voice2Img.dart';
import 'screens/Text2Img.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/UrduImageGeneratorPage.dart';
import 'screens/recent_images_screen.dart';
import 'screens/video_splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imagenia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFF24293E),
          secondary: Color(0xFF8EB8FF),
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const VideoSplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/userProfile': (context) => const UserProfilePage(),
        '/text2img': (context) => const Text2Img(),
        '/sketch': (context) => const Text2Sketch(), // Fixed route name
        '/reconstructImages': (context) => UrduImageGeneratorPage(),
        // '/voiceInput': (context) => const VoiceInputScreen(),
        '/voiceInput': (context) => const Voice2Img(),
        '/recent':(context) => const  RecentImagesScreen()
      },
    );
  }
}
