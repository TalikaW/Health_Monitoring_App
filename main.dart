import 'package:flutter/material.dart';
import 'user_login_page.dart';
import 'relative_login_page.dart';
import 'user_dashboard_page.dart';
import 'relative_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health System App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle named routes and pass arguments to the dashboard pages.
        if (settings.name == '/user_dashboard') {
          final String userName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => UserDashboardPage(relativeName: userName),
          );
        } else if (settings.name == '/relative_dashboard') {
          final String relativeName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RelativeDashboardPage(relativeName: relativeName),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const StartingPage(),
        '/user_login': (context) => const UserLoginPage(),
        '/relative_login': (context) => const RelativeLoginPage(),
      },
    );
  }
}

class StartingPage extends StatelessWidget {
  const StartingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_login');
              },
              child: const Text('User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/relative_login');
              },
              child: const Text('Relative'),
            ),
          ],
        ),
      ),
    );
  }
}
