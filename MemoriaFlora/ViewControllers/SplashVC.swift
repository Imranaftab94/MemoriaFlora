//
//  SplashVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performOperation()
    }
    
    private func performOperation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let _ = MyUserDefaults.getUser() {
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

}
