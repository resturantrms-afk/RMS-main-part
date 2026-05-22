import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_dashboard.dart';
import 'package:rmss/my_app.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(const KitchenDashboard());
}
