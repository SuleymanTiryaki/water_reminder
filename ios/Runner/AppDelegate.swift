import UIKit
import Flutter
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Bildirim izinlerini ayarla
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    // Background task'leri kaydet
    if #available(iOS 13.0, *) {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.fabirt.waterreminder.refresh",
        using: nil
      ) { task in
        self.handleBackgroundTask(task: task as! BGProcessingTask)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @available(iOS 13.0, *)
  func handleBackgroundTask(task: BGProcessingTask) {
    // Flutter method channel ile bildirimleri yenile
    let controller = window?.rootViewController as? FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.fabirt.waterreminder/background",
      binaryMessenger: controller!.binaryMessenger
    )
    
    channel.invokeMethod("refreshNotifications", arguments: nil) { result in
      task.setTaskCompleted(success: true)
    }
    
    // Bir sonraki background task'i planla
    scheduleBackgroundTask()
  }
  
  @available(iOS 13.0, *)
  func scheduleBackgroundTask() {
    let request = BGProcessingTaskRequest(identifier: "com.fabirt.waterreminder.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60) // 24 saat sonra
    request.requiresNetworkConnectivity = false
    request.requiresExternalPower = false
    
    do {
      try BGTaskScheduler.shared.submit(request)
      print("✅ Background task zamanlandı")
    } catch {
      print("❌ Background task zamanlama hatası: \(error)")
    }
  }
}
