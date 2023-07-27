import 'package:beat_blitz/constants.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final credentials = Constants.getSupaBaseCredentials();
  await Supabase.initialize(url: credentials[0], anonKey: credentials[1]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFdddef2)),
      home: const HomePage(),
    );
  }
}
