import 'package:bas_pay_flutter/bas_pay_flutter.dart';
import 'package:bas_pay_flutter/models/init_bas_sdk_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _basPayFlutterPlugin = BasPayFlutter();
  _BasPayExampleEnvironment _selectedEnvironment = _BasPayExampleEnvironment.sandbox;

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
  void dispose() {
    _trxTokenController.dispose();
    _userIdentifierController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  InitBasSdkModel _createInitBasSdkModel({
    required String trxToken,
    String? userIdentifier,
    String? fullName,
    String language = 'ar',
  }) {
    return switch (_selectedEnvironment) {
      _BasPayExampleEnvironment.prod => InitBasSdkModel.prod(
        trxToken: trxToken,
        userIdentifier: userIdentifier,
        fullName: fullName,
        language: language,
      ),
      _BasPayExampleEnvironment.dev => InitBasSdkModel.dev(
        trxToken: trxToken,
        userIdentifier: userIdentifier,
        fullName: fullName,
        language: language,
      ),
      _BasPayExampleEnvironment.sandbox => InitBasSdkModel.sandbox(
        trxToken: trxToken,
        userIdentifier: userIdentifier,
        fullName: fullName,
        language: language,
      ),
    };
  }

  Future<void> callBasPay() async {
    final String trxToken = _trxTokenController.text;
    final String userIdentifier = _userIdentifierController.text;
    final String fullName = _fullNameController.text;

    if (trxToken.isEmpty) {
      _showSnackBar('trxToken is required', isError: true);
      return;
    }

    /// init bas sdk model
    final InitBasSdkModel initBasSdkModel = _createInitBasSdkModel(
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

    try {
      final result = await _basPayFlutterPlugin.callBasPay(
        model: initBasSdkModel,
      );
      if (!mounted) {
        return;
      }
      if (result.resultStatus) {
        final resultModel = result.resultModel;
        if (resultModel?.status == true) {
          logger.d("""
          Success result message: ${resultModel?.message}
          status: ${resultModel?.status}
          result: ${resultModel?.result}
          code: ${resultModel?.code}
          """);
          _showSnackBar(resultModel?.message ?? 'Payment successful');
        } else {
          logger.e("""
          Failed result message: ${resultModel?.message}
          status: ${resultModel?.status}
          result: ${resultModel?.result}
          code: ${resultModel?.code}
          """);
          _showSnackBar(
            resultModel?.message ?? 'Payment failed',
            isError: true,
          );
        }
      } else {
        _showSnackBar(
          'Error calling bas pay flutter plugin',
          isError: true,
        );
      }
    } catch (error) {
      logger.e('callBasPay error: $error');
      _showSnackBar(error.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bas pay flutter example app')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _trxTokenController,
              decoration: const InputDecoration(hintText: 'trxToken'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdentifierController,
              decoration: const InputDecoration(hintText: 'userIdentifier'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(hintText: 'fullName'),
            ),
            const SizedBox(height: 16),
            _EnvironmentDropdown(
              selectedEnvironment: _selectedEnvironment,
              onChanged: (_BasPayExampleEnvironment environment) {
                setState(() {
                  _selectedEnvironment = environment;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: callBasPay,
              child: const Text('Call Bas Pay'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BasPayExampleEnvironment {
  prod,
  dev,
  sandbox,
}

class _EnvironmentDropdown extends StatelessWidget {
  const _EnvironmentDropdown({
    required this.selectedEnvironment,
    required this.onChanged,
  });

  final _BasPayExampleEnvironment selectedEnvironment;
  final ValueChanged<_BasPayExampleEnvironment> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_BasPayExampleEnvironment>(
      value: selectedEnvironment,
      decoration: const InputDecoration(hintText: 'environment'),
      items: _BasPayExampleEnvironment.values
          .map(
            (_BasPayExampleEnvironment environment) =>
                DropdownMenuItem<_BasPayExampleEnvironment>(
              value: environment,
              child: Text(environment.name),
            ),
          )
          .toList(),
      onChanged: (_BasPayExampleEnvironment? environment) {
        if (environment == null) {
          return;
        }
        onChanged(environment);
      },
    );
  }
}
