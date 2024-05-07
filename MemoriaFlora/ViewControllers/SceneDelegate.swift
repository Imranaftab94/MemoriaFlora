//
//  SceneDelegate.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/16/24.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var dynamicLink: DynamicLink?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Handle deep link when the app is opened with a URL
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }
        
        // Handle deep link when the app is opened with a user activity (Universal Links)
        if let userActivity = connectionOptions.userActivities.first {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
                handleDeepLink(url)
            }
        }
    }

    func handleDeepLink(_ deepUrl: URL?) {
        // Process the URL as needed
        print("Opened with URL: \(deepUrl)")
//        showAlertMsg(msg: "\(url)")
        
        if let url = deepUrl {
            DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
                guard error == nil else {
                    print("Error handling dynamic link: \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    // Dynamic link found, handle it
                    self.handleDynamicLink(dynamicLink)
                } else {
                    // Not a dynamic link
                    print("Not a dynamic link")
                }
            }
        }

        
        // Your logic to handle the deep link
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // 1
        if let url = userActivity.webpageURL {
            DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
                guard error == nil else {
                    print("Error handling dynamic link: \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    // Dynamic link found, handle it
                    self.handleDynamicLink(dynamicLink)
                } else {
                    // Not a dynamic link
                    print("Not a dynamic link")
                }
            }
        }
    }

    private func handleDynamicLink(_ dynamicLink: DynamicLink) {
        if let url = dynamicLink.url {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("Dynamic link URL: \(url)")
                if let url = dynamicLink.url,
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems {
                    guard let id = queryItems.first(where: { $0.name == "id" })?.value else {
                        return
                    }
                    
                    // Extracting memoryKey
                    guard let memoryKey = queryItems.first(where: { $0.name == "memoryKey" })?.value else {
                        return
                    }
                    
                    guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                        return
                    }
            
                    MyUserDefaults.setDynamicLink(url.absoluteString)
                    
                    let memory = Memory(uid: id, userName: "", description: "", imageUrl: "", dateOfDemise: "", timestamp: Date(), condolences: 0, memoryKey: memoryKey, createdByEmail: "", createdById: "", createdByName: "")
                    let vc = DetailViewController.instantiate(fromAppStoryboard: .Details)
                    vc.memory = memory
                    if let tabBarController = rootViewController as? MainTabbarController,
                       let navController = tabBarController.selectedViewController as? UINavigationController {
                        navController.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func showAlertMsg(msg: String?) {
            let alertController = UIAlertController(title: "Alert", message: "Your mexczcxzssage here \(msg)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true)
            }
        }
    
}
