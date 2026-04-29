import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/app.dart';
import 'package:tsiwa_mahber/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TsiwaApp());
}
