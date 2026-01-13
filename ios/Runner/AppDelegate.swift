import UIKit
import Flutter

/**
 * AppDelegate - Minimal Flutter App Delegate
 * 
 * Bildirimler: notification_scheduler plugin kullanılıyor
 * Eski background task sistemi: Kaldırıldı (Plugin kendi auto-refresh'ini yapıyor)
 */
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Bildirim izinlerini ayarla
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
