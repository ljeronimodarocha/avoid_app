import 'package:avoid_app/providers/auth_provider.dart';
import 'package:avoid_app/providers/video_provider.dart';
import 'package:avoid_app/utils/app_route.dart';
import 'package:avoid_app/views/auth_home.dart';
import 'package:avoid_app/views/auth_screen.dart';
import 'package:avoid_app/views/video_streaming.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, VideoProvider>(
          create: (_) => VideoProvider(),
          update: (ctx, auth, previousVideoProvider) =>
              VideoProvider(auth.token, previousVideoProvider!.items),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: AuthOrHome(),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoute.VIDEO: (ctx) => VideoStraming(),
          AppRoute.AUTH: (ctx) => AuthScreen(),
        },
      ),
    );
  }
}
