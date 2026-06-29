import 'bas_pay_flutter_platform_interface.dart';
import 'models/init_bas_sdk_model.dart';
import 'models/result_model.dart';

BasPayFlutterPlatform createPlatformInstance() => _WebPlaceholderBasPayFlutter();

class _WebPlaceholderBasPayFlutter extends BasPayFlutterPlatform {
  @override
  Future<({bool resultStatus, ResultModel? resultModel})> callBasPay({
    required InitBasSdkModel model,
  }) {
    throw UnimplementedError(
      'BasPayFlutterWeb has not been registered. '
      'Ensure the web plugin registrant runs before calling callBasPay.',
    );
  }
}
