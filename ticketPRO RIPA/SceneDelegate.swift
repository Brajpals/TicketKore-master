//
//  SceneDelegate.swift
//  ticketPRO RIPA
//
//  Created by Mamta yadav on 07/01/21.
//

import UIKit
import IQKeyboardManagerSwift

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        IQKeyboardManager.shared.enable = true
//        let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
//        if (login == 1){
//        let windowScene = UIWindowScene(session: session, connectionOptions: connectionOptions)
//           self.window = UIWindow(windowScene: windowScene)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(identifier: "DashBoardViewController") as? DashBoardViewController else {
//               print("ViewController not found")
//               return
//           }
//           let rootVC = UINavigationController(rootViewController: vc)
//           self.window?.rootViewController = rootVC
//           self.window?.makeKeyAndVisible()
//        }
 
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    
    func changeTheme(themeVal: String) {
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
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
         UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

