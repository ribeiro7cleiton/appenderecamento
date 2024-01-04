// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:enderecamento/pages/login.page.dart';
import 'package:asuka/asuka.dart' as asuka;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Endereçamento',
        theme: ThemeData(primarySwatch: Colors.green),
        builder: asuka.builder,
        navigatorObservers: [asuka.asukaHeroController],
        initialRoute: '/',
        routes: {'/': (_) => LoginPage()});
  }
}
