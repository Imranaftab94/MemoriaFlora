//
//  SplashVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

class SplashVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userId = AppController.shared.user?.userId {
            self.getUserFromDB(userId: userId)
        } else {
            self.performOperation()
        }
        
        // Example usage:
        if let currentLanguage = getCurrentLanguage() {
            print("Current language is set to: \(currentLanguage.rawValue)")
            DefaultManager.setAppLanguage(ver: currentLanguage.rawValue)
        } else {
            print("Language not supported")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func performOperation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let _ = AppController.shared.user, MyUserDefaults.getRememberMe() {
                // User exists, navigate to HomeViewController with animation
                let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarController") as! MainTabbarController
                animateTransition(to: homeVC, view: self.view)
            } else {
                // No user, navigate to LoginViewController with animation
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
    private func getUserFromDB(userId: String) {
        let databaseRef = Database.database().reference()
        
        let query = databaseRef.child("users").queryOrdered(byChild: "userId").queryEqual(toValue: userId).queryLimited(toFirst: 1)
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("User not found")
                return
            }
            
            if let userData = snapshot.children.allObjects.first as? DataSnapshot,
               let userDataDict = userData.value as? [String: Any] {
                print("User data: \(userDataDict)")
                
                if let isAdmin = userDataDict["admin"] as? Bool {
                    var user = AppController.shared.user
                    user?.admin = isAdmin
                    AppController.shared.user = user
                }
            }
            self.performOperation()
        } withCancel: { (error) in
            print("Error fetching user data: \(error.localizedDescription)")
            self.showAlert(message: "User not found".localized())
        }
    }
}
