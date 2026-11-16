import 'package:daynest/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/note_provider.dart';
import 'providers/task_provider.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

// Entry point of the Daynest app.
Future<void> main() async {
  // Needed before using any plugin (such as Firebase) in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Connects the app to your Firebase project.
  // The settings come from lib/firebase_options.dart.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Turns on offline persistence for Firestore.
  FirebaseService.configureFirestore();

  runApp(const DaynestApp());
}

class DaynestApp extends StatelessWidget {
  const DaynestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider knows who is signed in.
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. TaskProvider and NoteProvider are linked to the login.
        // Whenever the signed-in user changes, they are told the new
        // user id (or null when logged out) and load only that
        // user's data.
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, auth, taskProvider) {
            taskProvider!.setUser(auth.user?.uid);
            return taskProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NoteProvider>(
          create: (_) => NoteProvider(),
          update: (_, auth, noteProvider) {
            noteProvider!.setUser(auth.user?.uid);
            return noteProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Daynest',
        debugShowCheckedModeBanner: false,
        // Our custom theme from lib/theme/app_theme.dart
        theme: AppTheme.lightTheme,

        // Flow: Splash -> Onboarding -> Login
        // (The splash screen skips ahead if the user is already signed in.)
        home: const SplashScreen(
          nextScreen: OnboardingScreen(nextScreen: LoginScreen()),
        ),

        // Named routes used across the app
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const MainShell(),
        },
      ),
    );
  }
}