import 'package:avoid_app/providers/auth_provider.dart';
import 'package:avoid_app/views/auth_screen.dart';
import 'package:avoid_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthOrHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    return FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('Ocorreu um erro!'),
            );
          } else {
            return auth.isAuth ? HomeScreen() : AuthScreen();
          }
        });
  }
}
