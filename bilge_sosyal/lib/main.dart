
import 'package:bilge_sosyal/responsive/screen_layout.dart';
import 'package:bilge_sosyal/screens/admin_screen.dart';
import 'package:bilge_sosyal/screens/homepage2.dart';
import 'package:bilge_sosyal/screens/intro_screen.dart';
import 'package:bilge_sosyal/screens/login_screen.dart';
import 'package:bilge_sosyal/screens/newadmin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bilge_sosyal/screens/admin_screen.dart';
import 'package:bilge_sosyal/screens/splash.dart';
import 'package:bilge_sosyal/screens/chat.dart';
import 'firebase_options.dart';
import 'package:bilge_sosyal/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class AppTheme {
  static bool isDarkMode = false;

  static ThemeData get themeData {
    return isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  static void toggleDarkMode() {
    isDarkMode = !isDarkMode;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilge',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(242, 0, 155, 226)),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors
            .blue, // Karanlık modda da aynı renk temasını kullanabilirsiniz
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return  const MobileScreenLayout();
            }

            return  const OnBoardingScreen();
          }),
    );
  }
}
