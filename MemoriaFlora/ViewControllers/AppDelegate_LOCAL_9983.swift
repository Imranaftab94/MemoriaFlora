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
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true
        FirebaseApp.configure()
            

        return true
    }
        
    // In your AppDelegate.swift file
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle the URL (e.g., deep link)
        handleDeepLink(url)
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // On progress
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            print("dynamic link = \(dynamiclink)")
        }
        
        if handled {
            
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Details", bundle: nil)
            if let initialViewController : UIViewController = (mainStoryboardIpad.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController) {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
            
            return handled
        }
        
        return false
    }
    
    func handleDeepLink(_ url: URL) {
        // Process the URL as needed (e.g., extract parameters)
        // You may also want to navigate to the appropriate view controller based on the deep link
        print("Opened with URL: \(url)")
        showAlertMsg()
        // Your logic to handle the deep link
    }
    
    func showAlertMsg() {
        let alertController = UIAlertController(title: "Alert", message: "Your messhjgghjgjkjkgage here", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true)
        }
    }

}
