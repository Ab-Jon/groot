import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groot/screens/splash_screen.dart';
import 'authenticate/sign_in.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await Purchases.setDebugLogsEnabled(true);
  // await Purchases.configure(PurchasesConfiguration("goog_koYjsbsSospeRYegQxvBkozGjhc"));
  // await FirebaseAppCheck.instance.activate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
        routes: {
          '/signIn': (context) => SignIn(), // Sign-in screen
        },
    title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
