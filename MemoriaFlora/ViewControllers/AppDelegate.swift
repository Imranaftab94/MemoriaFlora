//
//  AppDelegate.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/16/24.
//

import UIKit
import IQKeyboardManager
import FirebaseCore
import FirebaseDynamicLinks
import GoogleSignIn
import UserNotifications
import Messages
import Firebase
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true
        FirebaseApp.configure()
        window?.overrideUserInterfaceStyle = .light
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        self.registerForPushNotifications()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
        
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//        ApplicationDelegate.shared.application(
//            app,
//            open: url,
//            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        if let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//           let annotation = options[UIApplication.OpenURLOptionsKey.annotation] {
//            // Handle the URL for Facebook login
//            return ApplicationDelegate.shared.application(
//                app,
//                open: url,
//                sourceApplication: sourceApplication,
//                annotation: annotation
//            )
//        } else {
//            // Handle the URL for Google Sign-In
//            return GIDSignIn.sharedInstance.handle(url)
//        }
//    }

//    // In your AppDelegate.swift file
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        // Handle the URL (e.g., deep link)
//        handleDeepLink(url)
//        return true
//    }
//
//    func handleDeepLink(_ url: URL) {
//        // Process the URL as needed (e.g., extract parameters)
//        // You may also want to navigate to the appropriate view controller based on the deep link
//        print("Opened with URL: \(url)")
//        showAlertMsg()
//        // Your logic to handle the deep link
//    }
//    
//    func showAlertMsg() {
//        let alertController = UIAlertController(title: "Alert", message: "Your messhjgghjgjkjkgage here", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        
//        
//        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
//            rootViewController.present(alertController, animated: true)
//        }
//    }

}
