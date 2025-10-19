import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {

            print("✅ Received URL from BankyLite:", url.absoluteString)
            let userInfoKey = "URL_KEY"
            let notificationName = Notification.Name("BankyLiteResponseNotification")
            let urlString = url.absoluteString
            
            let userInfo = [userInfoKey: urlString]

            // أرسل إشعاراً إلى Kotlin observer
            NotificationCenter.default.post(
                name: notificationName,
                object: nil,
                userInfo: userInfo
            )

            // ارجع true لتأكيد المعالجة
            return true
        }

}
