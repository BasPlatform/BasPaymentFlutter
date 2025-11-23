import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bas_pay_flutter_platform_interface.dart';
import 'models/init_bas_sdk_model.dart';
import 'models/result_model.dart';

/// An implementation of [BasPayFlutterPlatform] that uses method channels.
class MethodChannelBasPayFlutter extends BasPayFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bas_pay_flutter');


  @override
  Future<({bool resultStatus, ResultModel? resultModel})> callBasPay({required InitBasSdkModel model}) async {
    dynamic modelData;
    if(Platform.isAndroid){
      modelData = model.toJson();
    }else{
      modelData = jsonEncode(model.toJson());
    }
    // final String modelJson = jsonEncode(model.toJson());
    final result = await methodChannel.invokeMethod<String>('callBasPay', modelData);
    if(result == null){
      return (resultStatus: false, resultModel: null);
    }
    try {
      final resultModel = ResultModel.fromJson(result);
      return (resultStatus: true, resultModel: resultModel);
    }catch (e){
      return (resultStatus: false, resultModel: null);
    }

  }

}
