import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  // Ensure consistent platform behavior
  WidgetsFlutterBinding.ensureInitialized();

  // Run app with error boundary
  runApp(
    const MyApp(),
  );
}