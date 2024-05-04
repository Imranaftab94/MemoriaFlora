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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.performOperation()
    }
    
    private func performOperation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let _ = AppController.shared.user, MyUserDefaults.getRememberMe() {
                // User exists, navigate to HomeViewController with animation
                let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                let navigationVC = UINavigationController(rootViewController: homeVC)
                animateTransition(to: navigationVC, view: self.view)
            } else {
                // No user, navigate to LoginViewController with animation
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
    private func getUserFromDB(email: String) {
        let databaseRef = Database.database().reference()
        
        let query = databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).queryLimited(toFirst: 1)
        self.showProgressHUD()
        query.observeSingleEvent(of: .value) { (snapshot) in
            self.hideProgressHUD()
            guard snapshot.exists() else {
                print("User not found")
                self.navigateToHome()
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
            self.navigateToHome()
        } withCancel: { (error) in
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    private func navigateToHome() {
        DispatchQueue.main.async {
            let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationVC = UINavigationController(rootViewController: homeVC)
            animateTransition(to: navigationVC, view: self.view)
        }
    }
}
