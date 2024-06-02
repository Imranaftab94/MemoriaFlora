//
//  ProfileViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: BaseViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBackButtonColor()
        self.title = "Profile"
        self.nameLabel.text = AppController.shared.user?.name ?? "User"
        self.userImageView.layer.cornerRadius = 16
        self.userImageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        if AppController.shared.user?.admin ?? false {
            self.deleteButton.isHidden = true
        }
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    func deleteAccount() {
        reaAuthenticate()
    }
    
    private func reaAuthenticate() {
        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        // Create an alert controller to prompt the user for their password
        let passwordPromptController = UIAlertController(title: "Reauthentication", message: "Please enter your password to proceed", preferredStyle: .alert)
        
        // Add a text field to the alert controller for the password input
        passwordPromptController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        // Add actions to the alert controller
        passwordPromptController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        passwordPromptController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Retrieve the password entered by the user
            if let password = passwordPromptController.textFields?.first?.text {
                // Reauthenticate the user with the entered password
                let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
                
                self.showProgressHUD()
                user.reauthenticate(with: credential) { authResult, error in
                    self.hideProgressHUD()
                    if let error = error {
                        // Handle reauthentication error
                        print("Reauthentication error: \(error.localizedDescription)")
                        self.showAlert(message: "Failed to reauthenticate: \(error.localizedDescription)")
                        return
                    }
                    
                    // Reauthentication successful, proceed with account deletion
                    user.delete { error in
                        if let error = error {
                            // An error happened while deleting the user account
                            print("An error occurred while trying to delete the user: \(error.localizedDescription)")
                            self.showAlert(message: "Failed to delete user: \(error.localizedDescription)")
                        } else {
                            // User account deleted successfully
                            // Perform any additional cleanup or navigation
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
                                    // Navigate to another screen or show a confirmation message
                                    MyUserDefaults.removeUser()
                                    AppController.shared.user = nil
                                    AppController.shared.fcmToken = ""
                                    let splashVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                                    let navigationVC = UINavigationController.init(rootViewController: splashVC)
                                    UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                        UIApplication.shared.windows.first?.rootViewController = navigationVC
                                    }, completion: nil)
                                }
                            }
                        }
                    }
                }
            } else {
                // Handle case where no password was entered
                print("No password entered")
                self.showAlert(message: "Please enter your password to proceed")
            }
        }))
        
        self.present(passwordPromptController, animated: true)
    }

    @IBAction func onClickLogoutButton(_ sender: UIButton) {
        MyUserDefaults.removeUser()
        AppController.shared.user = nil
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
