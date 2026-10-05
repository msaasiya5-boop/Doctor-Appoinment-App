import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicare_connect/admin/adminlogin.dart';
import 'package:medicare_connect/screen/splash.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/provider_auth.dart';

Future<void> main() async {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppAuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Medicare Connect",
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
