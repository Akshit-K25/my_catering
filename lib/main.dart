import 'package:flutter/material.dart';
import 'feed.dart';
import 'orders.dart';
import 'update.dart';
import 'analyze.dart';

void main() {
  runApp(MaterialApp(
    home: OrderPage(),
    routes: {
      '/feeds': (context) => OrderPage(),
      '/orders': (context) => OrdersPage(),
      '/update': (context) => UpdatePage(),
      '/analyze': (context) => AnalyzePage(),
    },
    debugShowCheckedModeBanner: false,
  ));
}