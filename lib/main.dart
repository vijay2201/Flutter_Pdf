import 'package:flutter/material.dart';

import 'invoice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: CreatePdfStatefulWidget(title: 'Create PDF document'),
    );
  }
}

