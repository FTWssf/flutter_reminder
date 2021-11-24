import UIKit
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // Flutter WorkManager
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    // Work Manager Foreground Debug Notification
    // UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)
    WorkmanagerPlugin.register(with: self.registrar(forPlugin: "be.tramckrijte.workmanager.WorkmanagerPlugin")!)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Work Manager Foreground Debug Notification
  // override func userNotificationCenter(_ center: UNUserNotificationCenter,
  //                                        willPresent notification: UNNotification,
  //                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
  //        completionHandler(.alert) // shows banner even if app is in foreground
  //    }

}
