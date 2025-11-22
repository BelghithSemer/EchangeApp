import 'package:devmob_echange/views/auth/login_page.dart';
import 'package:devmob_echange/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:devmob_echange/providers/auth_provider.dart';
import 'package:devmob_echange/providers/item_provider.dart'; // AJOUTEZ CET IMPORT
import 'package:devmob_echange/services/firebase_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()), // AJOUTEZ CE PROVIDER
      ],
      child: MaterialApp(
        title: 'DEVMOB Echange',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.appUser != null
                ? HomePage()
                : LoginPage();
          },
        ),
      ),
    );
  }
}