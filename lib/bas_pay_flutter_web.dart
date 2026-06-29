import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'bas_pay_flutter_platform_interface.dart';
import 'models/init_bas_sdk_model.dart';
import 'models/result_model.dart';
import 'web/bas_pay_popup_bridge.dart';

/// A web implementation of [BasPayFlutterPlatform] for the BasPayFlutter plugin.
class BasPayFlutterWeb extends BasPayFlutterPlatform {
  /// Constructs a [BasPayFlutterWeb].
  BasPayFlutterWeb({BasPayPopupBridge? popupBridge})
    : _popupBridge = popupBridge ?? BasPayPopupBridge();

  final BasPayPopupBridge _popupBridge;

  /// Registers this plugin with the Flutter web engine.
  static void registerWith(Registrar registrar) {
    BasPayFlutterPlatform.instance = BasPayFlutterWeb();
  }

  @override
  Future<({bool resultStatus, ResultModel? resultModel})> callBasPay({
    required InitBasSdkModel model,
  }) {
    return _popupBridge.openAndWaitForResult(model: model);
  }
}
