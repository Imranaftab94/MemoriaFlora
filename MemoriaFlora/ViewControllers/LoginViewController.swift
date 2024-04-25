//
//  LoginViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: BaseViewController {
    @IBOutlet weak var rememberMeSwitchButton: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onClickSwitchButton(_ sender: UISwitch) {
        
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
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
        
        self.showProgressHUD()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            self.hideProgressHUD()
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.showAlert(message: error.localizedDescription)
            } else {
                print("User successfully signed in")
                
                if let user = authResult?.user {
                    if self.rememberMeSwitchButton.isOn {
                        let user = User(name: user.displayName ?? "", email: self.emailTextField.text!, userDescription: user.description)
                        MyUserDefaults.setUser(user)
                    }
                    DispatchQueue.main.async {
                        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        let navigationVC = UINavigationController(rootViewController: homeVC)
                        animateTransition(to: navigationVC, view: self.view)
                    }
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
