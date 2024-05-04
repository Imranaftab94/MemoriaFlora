//
//  ProfileViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBackButtonColor()
        self.title = "Profile"
        self.nameLabel.text = AppController.shared.user?.name ?? "User"
        self.userImageView.layer.cornerRadius = 16
        self.userImageView.layer.masksToBounds = true
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
        func deleteAccount() {
            guard let user = Auth.auth().currentUser else {
                // No user is signed in, handle the error or show a message
                return
            }

            // Prompt the user to confirm account deletion
            let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Get a reference to the users node in the database
                let databaseRef = Database.database().reference()
                let userRef = databaseRef.child("users").child(user.uid)
                
                // Delete user data from the database
                userRef.removeValue { error, _ in
                    if let error = error {
                        // An error occurred while deleting user data
                        print("Error deleting user data: \(error.localizedDescription)")
                        // Handle the error or show an error message
                    } else {
                        // User data deleted successfully
                        print("User data deleted successfully")
                        
                        // Delete user account from Firebase Authentication
                        user.delete { error in
                            if let error = error {
                                // An error occurred while deleting the account
                                print("Error deleting account: \(error.localizedDescription)")
                                // Handle the error or show an error message
                            } else {
                                // Account deleted successfully
                                print("Account deleted successfully")
                                // Navigate to another screen or show a confirmation message
                                MyUserDefaults.removeUser()
                                let splashVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                                let navigationVC = UINavigationController.init(rootViewController: splashVC)
                                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                    UIApplication.shared.windows.first?.rootViewController = navigationVC
                                }, completion: nil)

                            }
                        }
                    }
                }
            }))
            
            // Present the alert controller
            self.present(alertController, animated: true, completion: nil)
        }

    @IBAction func onClickLogoutButton(_ sender: UIButton) {
        MyUserDefaults.removeUser()
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }

        let splashVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        let navigationVC = UINavigationController.init(rootViewController: splashVC)
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            UIApplication.shared.windows.first?.rootViewController = navigationVC
        }, completion: nil)
    }
    
    @IBAction func deleteButtonTap(_ sender: UIButton) {
        deleteAccount()
    }
}
