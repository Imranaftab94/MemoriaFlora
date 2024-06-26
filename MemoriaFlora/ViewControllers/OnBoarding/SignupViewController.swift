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

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func localized() {
        self.loginButton.setTitle("Login".localized(), for: .normal)
        self.createAccount.setTitle("Create Account", for: .normal)
    }
    

    
    @IBAction func signupTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter your name".localized())
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email".localized())
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email".localized())
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter a password".localized())
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please confirm your password".localized())
            return
        }
        
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match".localized())
            return
        }
        
        self.showProgressHUD()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            self.hideProgressHUD()
            if let error = error {
                print("An error occurred during sign-up", error.localizedDescription)
                self.showAlert(message: error.localizedDescription)
                return
            } else {
                print(" User successfully signed up")
                
                if let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.nameTextField.text!
                   
                    // Create a reference to the Firebase Realtime Database
                    let databaseRef = Database.database().reference()
                    
                    // Save user data under the user ID
                    let userData: [String: Any] = [
                        "name": self.nameTextField.text!,
                        "email": self.emailTextField.text!.lowercased(),
                        "userDescription": "",
                        "admin": false,
                        "userId": user.uid,
                        "fcmToken": ""
                    ]
                    
                    guard let uid = authResult?.user.uid else {
                        return
                    }
                    
                    databaseRef.child(kUusers).child(uid).setValue(userData) { (error, ref) in
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
                            self.showAlert(message: "User signed up successfully!".localized()) {
                                self.navigationController?.popViewController(animated: true)
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
        let alert = UIAlertController(title: "Alert".localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default) { _ in
            okHandler?() // Call the handler if provided
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
