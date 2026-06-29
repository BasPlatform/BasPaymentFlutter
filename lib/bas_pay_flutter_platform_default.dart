import 'bas_pay_flutter_platform_interface.dart';
import 'bas_pay_flutter_method_channel.dart'
    if (dart.library.html) 'bas_pay_flutter_web_platform_stub.dart' as impl;

BasPayFlutterPlatform get defaultBasPayFlutterPlatform =>
    impl.createPlatformInstance();
