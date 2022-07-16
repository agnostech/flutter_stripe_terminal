import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_stripe_terminal/flutter_stripe_terminal.dart';
import 'package:http/http.dart' as http;

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
      "http://devapi.custofood.com/api/payments/connection_token", "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjYyNywiaXNzIjoiaHR0cDovL2RldmFwaS5jdXN0b2Zvb2QuY29tL2FwaS9sb2dpbiIsImlhdCI6MTY0NDQwODk5NCwiZXhwIjoxNjQ3MDAwOTk0LCJuYmYiOjE2NDQ0MDg5OTQsImp0aSI6ImNVY0I5b0RJRTU5dXRhSk4ifQ.O9ML8yibl6J_8Zgd_ZV4JW1uijV6YZynKxMZA5YOsY0"
      )
    .then((value) => FlutterStripeTerminal.startTerminalEventStream())
    .then((value) => FlutterStripeTerminal.searchForReaders())
    .catchError((error) => print(error));

    FlutterStripeTerminal.readersList.listen((List<Reader> readersList) {
      setState(() {
        readers = readersList;
      });
    });

    FlutterStripeTerminal.readerConnectionStatus.listen((ReaderConnectionStatus connectionStatus) {
      print(connectionStatus);
    });

    FlutterStripeTerminal.readerPaymentStatus.listen((ReaderPaymentStatus paymentStatus) {
      print(paymentStatus);
    });

    FlutterStripeTerminal.readerUpdateStatus.listen((ReaderUpdateStatus updateStatus) {
      print(updateStatus);
    });

    FlutterStripeTerminal.readerEvent.listen((ReaderEvent readerEvent) {
      print(readerEvent);
    });

    FlutterStripeTerminal.readerInputEvent.listen((String readerInputEvent) {
      print(readerInputEvent);
    });
  }

  void initiatePayment() async {
    final url = Uri.parse("http://devapi.custofood.com/api/payments/payment_intent");
    final response = await http.post(url, body: {
      'amount': '1'
    }, headers: {
      'Authorization': "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjYyNywiaXNzIjoiaHR0cDovL2RldmFwaS5jdXN0b2Zvb2QuY29tL2FwaS9sb2dpbiIsImlhdCI6MTY0NDQwODk5NCwiZXhwIjoxNjQ3MDAwOTk0LCJuYmYiOjE2NDQ0MDg5OTQsImp0aSI6ImNVY0I5b0RJRTU5dXRhSk4ifQ.O9ML8yibl6J_8Zgd_ZV4JW1uijV6YZynKxMZA5YOsY0"
    });

    print(response.body);

    String intentId = await FlutterStripeTerminal.processPayment(jsonDecode(response.body)['client_secret']);

    print(intentId);
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
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: () {
                    initiatePayment();
                  }, child: Text('Initiate payment')),
                  ListView.builder(
                    shrinkWrap: true,
                  itemCount: readers.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      onTap: () async {
                        await FlutterStripeTerminal.connectToReader(readers[position].serialNumber, "tml_EZ3aRgXYNvd1Qo");
                      },
                      title: Text(readers[position].deviceName),
                    );
                  },
                )
                ],
              )),
    );
  }
}
