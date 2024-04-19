//
//  ProfileViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBackButtonColor()
        self.title = "Profile"
        
        self.userImageView.layer.cornerRadius = 16
        self.userImageView.layer.masksToBounds = true
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    @IBAction func onClickLogoutButton(_ sender: UIButton) {
        MyUserDefaults.removeUser()
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            UIApplication.shared.windows.first?.rootViewController = homeVC
        }, completion: nil)
    }
}
