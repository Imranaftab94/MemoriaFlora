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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true
        FirebaseApp.configure()
        return true
    }
    
    func showAlertMsg() {
        let alertController = UIAlertController(title: "Alert", message: "Your message here", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true)
        }
    }
    
}
