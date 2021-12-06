//
//  AppDelegate.swift
//  ticketPRO RIPA
//
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 14, *) {
            let picker = UIDatePicker.appearance()
            picker.preferredDatePickerStyle = .wheels
        }
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        IQKeyboardManager.shared.enable = true
        AppConstants.bioLogin = "0"
        
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else{
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
//        if (login == 1){
//
//        }
//      }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
 
                 let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
                if (login == 1){
                    let story = UIStoryboard(name: "Main", bundle:nil)
                    let vc = story.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                     let rootVC = UINavigationController(rootViewController: vc)
                     UIApplication.shared.windows.first?.rootViewController = rootVC
                     UIApplication.shared.windows.first?.makeKeyAndVisible()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vc.demo(tag:2)
                    }
                 }
   
        completionHandler()
    }
    
    
    
   
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
        if (login == 1){
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        AppConstants.deviceToken = fcmToken!
      }
        else{
          //  UIApplication.shared.unregisterForRemoteNotifications()
        }
 
    }
    
    
    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
        if (login == 1){
            print("awdawdawd")
           // UIApplication.shared.applicationIconBadgeNumber = 5
        }
    }
    
 
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    
    
    
    
    func changeTheme(themeVal: String) {
        if #available(iOS 13.0, *) {
            switch themeVal {
            case "dark":
                window?.overrideUserInterfaceStyle = .dark
                break
            case "light":
                window?.overrideUserInterfaceStyle = .light
                break
            default:
                window?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    
    
}

