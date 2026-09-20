import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/favorites_provider.dart';
import 'providers/job_provider.dart';
import 'providers/theme_provider.dart';
import 'services/job_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<JobService>(
          create: (_) => JobService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..load(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider()..load(),
        ),
        ChangeNotifierProvider<JobProvider>(
          create: (context) => JobProvider(context.read<JobService>())..load(),
        ),
      ],
      child: const JobNestApp(),
    ),
  );
}
