import 'package:flutter/material.dart';

import 'ui/splash/splash_screen.dart';
import 'ui/auth/login/login_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/order/order_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (ctx) => const SplashScreen(nextRoute: LoginScreen.routeName),
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        OrderScreen.routeName: (ctx) => const OrderScreen(),
      },
    );
  }
}
