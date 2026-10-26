import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homrix/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:homrix/app/app.dart' show HomrixApp;
export 'package:homrix/features/listings/presentation/views/home_explore_screen.dart'
    show BlankHomeScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
  final configuredPublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY']
      ?.trim();
  final legacyAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
  final supabasePublishableKey =
      configuredPublishableKey != null && configuredPublishableKey.isNotEmpty
      ? configuredPublishableKey
      : legacyAnonKey;

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabasePublishableKey == null ||
      supabasePublishableKey.isEmpty) {
    runApp(const _SupabaseConfigurationRequiredApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const HomrixApp());
}

class _SupabaseConfigurationRequiredApp extends StatelessWidget {
  const _SupabaseConfigurationRequiredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homrix configuration',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Supabase is not configured. Copy .env.example to .env and add '
              'your project URL and public publishable/anon key.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
