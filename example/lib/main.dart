import 'package:flutter/material.dart';

import 'package:flutter_stripe_terminal/flutter_stripe_terminal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Reader> readers = [];

  @override
  void initState() {
    super.initState();
    FlutterStripeTerminal.readersList.listen((List<Reader> readersList) {
      setState(() {
        readers = readersList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Stripe Terminal'),
          ),
          body: readers.length > 0
              ? Center(
                  child: Text('No devices found'),
                )
              : ListView.builder(
                  itemCount: readers.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      title: Text(readers[position].deviceName),
                    );
                  },
                )),
    );
  }
}
