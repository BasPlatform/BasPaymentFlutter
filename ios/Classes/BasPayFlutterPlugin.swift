import Flutter
import UIKit
import bas_pay
//import Foundation




public class BasPayFlutterPlugin: NSObject, FlutterPlugin {

  struct BasArgs : Decodable {
      var trxToken: String
      var userIdentifier: String?
      var fullName: String?
      var language: String?
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bas_pay_flutter", binaryMessenger: registrar.messenger())
    let instance = BasPayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "callBasPay":

//    print("callBasPay called with arguments: \(call.arguments)")
    let args = (call.arguments as! String).data(using:.utf8)!
    var convertArgs: BasArgs?

    do {
        convertArgs = try JSONDecoder().decode(BasArgs.self, from: args)
//        print(convertArgs)
    } catch {
//        print("Error decoding arguments: \(error)")
        print(error)
    }




      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
          let rootViewController = keyWindow.rootViewController else {
          result(FlutterError(code: "ERROR",
          message: "Could not get rootViewController to present from.",
          details: nil))
        return
     }

      let newNativeViewController = BasMainIosKt.BasMainIosController(
       trxToken : convertArgs!.trxToken,
       userIdentifier : convertArgs?.userIdentifier,
       fullName : convertArgs?.fullName,
       language : convertArgs?.language,
       onReturnDataToIOS : {
        [weak self] dataFromCompose in
        rootViewController.dismiss(animated: true, completion: nil)
        result(dataFromCompose)
       }
       )

        let navControllerForModal = UINavigationController(rootViewController: newNativeViewController)
        rootViewController.present(navControllerForModal, animated: true, completion:nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }


}
