import 'package:flutter/material.dart';
import 'library_screen.dart';

class LibraryWrapper extends StatelessWidget {
  const LibraryWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Independent navigation stack
    return Navigator(
      onGenerateRoute: (settings) {
        // Initial library route
        return MaterialPageRoute(
          builder: (context) => const LibraryScreen(),
        );
      },
    );
  }
}