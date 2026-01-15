import 'package:bas_pay_flutter/models/init_bas_sdk_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bas_pay_flutter/bas_pay_flutter.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _basPayFlutterPlugin = BasPayFlutter();

  /// controller for text field
  final _trxTokenController = TextEditingController(
    // text: "Bn4//SoP3kgkNjAxYTRhMDMtZTQxMy00MjY4LWJhM2MtNzk3NDhkMjM3ZTcyUFkGNTk2OTEx"
    text:
        !kDebugMode
            ? null
            : "9n3DhB6W3UgkZWMwNWQ4YTYtZGI3NC00YTNmLWJhNmYtNDZlNmE1NjA5ZmE0UFkGNTM0ODk3",
  );
  final _userIdentifierController = TextEditingController(
    // text: !kDebugMode ? null : "777111222"
  );
  final _fullNameController = TextEditingController(
    // text: !kDebugMode ? null : "Ahmed"
  );

  @override
  void initState() {
    super.initState();
  }

  callBasPay() async {
    print('callBasPay called');
    final String trxToken = _trxTokenController.text;
    final String userIdentifier = _userIdentifierController.text;
    final String fullName = _fullNameController.text;

    if (trxToken.isEmpty) {
      return;
    }

    /// init bas sdk model
    final InitBasSdkModel initBasSdkModel = InitBasSdkModel.dev(
      /// trxToken is required
      trxToken: trxToken,

      /// userIdentifier is optional, default value is null
      /// example: userIdentifier: "733733733" phone number
      // userIdentifier: userIdentifier.isEmpty ? null : userIdentifier,
      /// fullName is optional, default value is null
      // fullName: fullName.isEmpty ? null : fullName,
      /// language is optional, default value is "ar"
      /// you can change it to "en" if you want to use English language instead of Arabic
      // language: "ar",
    );

    /// call bas pay plugin and wait for result
    final result = await _basPayFlutterPlugin.callBasPay(
      model: initBasSdkModel,
    );
    if (result.resultStatus) {
      if (result.resultModel?.status == true) {
        logger.d("""
        Success result message: ${result.resultModel?.message}
        status: ${result.resultModel?.status}
        result: ${result.resultModel?.result}
        code: ${result.resultModel?.code}
        """);
      } else {
        logger.e("""
        Failed result message: ${result.resultModel?.message}
        status: ${result.resultModel?.status}
        result: ${result.resultModel?.result}
        code: ${result.resultModel?.code}
          """);

        throw Exception(
          "Bas Pay SDK Error ====> ${result.resultModel?.message}",
        );
      }
    } else {
      throw Exception("Error calling bas pay flutter plugin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('bas pay flutter example app')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _trxTokenController,
                decoration: InputDecoration(hintText: 'trxToken'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _userIdentifierController,
                decoration: InputDecoration(hintText: 'userIdentifier'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(hintText: 'fullName'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await callBasPay();
                },
                child: Text('Call Bas Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
