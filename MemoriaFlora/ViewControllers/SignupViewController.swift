//
//  SignupViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseDynamicLinks

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter your name")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter a password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please confirm your password")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }
        
        self.showProgressHUD()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            self.hideProgressHUD()
            if let error = error {
                print("An error occurred during sign-up", error.localizedDescription)
            } else {
                print(" User successfully signed up")
                
                if let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.nameTextField.text!
                    let user = User(name: self.nameTextField.text!, email: self.emailTextField.text!, userDescription: "")
                    MyUserDefaults.setUser(user)
                    
                    // Create a reference to the Firebase Realtime Database
                    let databaseRef = Database.database().reference()
                    
                    // Save user data under the user ID
                    let userData: [String: Any] = [
                        "name": self.nameTextField.text!,
                        "email": self.emailTextField.text!,
                        "userDescription": ""
                    ]
                    
                    guard let uid = authResult?.user.uid else {
                        return
                    }
                    
                    databaseRef.child("users").child(uid).setValue(userData) { (error, ref) in
                        if let error = error {
                            print("An error occurred while saving user data: \(error.localizedDescription)")
                        } else {
                            print("User data saved successfully!")
                        }
                    }
                    
                    changeRequest.commitChanges(completion: { error in
                        if let error = error {
                            print("An error occurred during naming-up", error.localizedDescription)
                        } else {
                            self.showAlert(message: "User signed up successfully!") {
                                let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                                let navigationVC = UINavigationController(rootViewController: homeVC)
                                animateTransition(to: navigationVC, view: self.view)
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func showAlert(message: String, okHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okHandler?() // Call the handler if provided
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {

//        guard let link = URL(string: "https://memoriaflora.page.link?id=2") else { return }
//        let dynamicLinksDomain = "https://memoriaflora.page.link"
//        
//        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain)//DynamicLinkComponents(link: link, domain: dynamicLinksDomain)
//        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.MemoriaFlora.App")
//        linkBuilder?.iOSParameters?.appStoreID = "6499025659"
//
//        linkBuilder?.shorten { (shortURL, _, error) in
//            if let error = error {
//                print("Error creating dynamic link: \(error.localizedDescription)")
//                return
//            }
//            if let shortURL = shortURL {
//                print("Short URL: \(shortURL)")
//                // Share or use the short URL as needed
//            }
//        }

        self.navigationController?.popViewController(animated: true)
    }
}
