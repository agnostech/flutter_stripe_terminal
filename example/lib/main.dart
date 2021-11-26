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
    FlutterStripeTerminal.setConnectionTokenParams(
      "YOUR_CONNECTION_TOKEN_API", "YOUR_AUTHORIZATION_TOKEN_FOR_API"
      )
    .then((value) => FlutterStripeTerminal.startTerminalEventStream())
    .then((value) => FlutterStripeTerminal.searchForReaders())
    .catchError((error) => print(error));

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
          body: readers.length == 0
              ? Center(
                  child: Text('No devices found'),
                )
              : ListView.builder(
                  itemCount: readers.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      onTap: () async {
                        await FlutterStripeTerminal.connectToReader(readers[position].serialNumber);
                        print("reader connected");
                      },
                      title: Text(readers[position].deviceName),
                    );
                  },
                )),
    );
  }
}
