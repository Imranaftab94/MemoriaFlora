//
//  LoginViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FirebaseCore

class LoginViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var rememberMeSwitchButton: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var linkTextView: UITextView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        
    }
    
    private func configureViews() {
        let text = "Caro Estinto uses cookies for analytics, personalized contents and ads, using Caro Estinto's service you agree with Policy and Rules."
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let policyRange = (text as NSString).range(of: "Policy")
        let rulesRange = (text as NSString).range(of: "Rules")
        
        attributedString.addAttribute(.link, value: "http://caroestinto.com/privatepolicy/", range: policyRange)
        attributedString.addAttribute(.link, value: "http://caroestinto.com/rules/", range: rulesRange)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: policyRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: rulesRange)
        
        // Set font size
        let fontSize: CGFloat = 13.0
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: attributedString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        linkTextView.attributedText = attributedString
        linkTextView.isUserInteractionEnabled = true
        linkTextView.isEditable = false
        linkTextView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return true
    }
    
    @IBAction func onClickSwitchButton(_ sender: UISwitch) {
        
    }
    
    @IBAction func onClickFacebookButton(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickLoginButton(_ sender: UIButton) {
        self.showProgressHUD()
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.hideProgressHUD()
            return
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            self.hideProgressHUD()
            return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            self.hideProgressHUD()
            return
          }

            print("Auth Google id Token : ",idToken)
          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          print(credential)
            Auth.auth().signIn(with: credential) { authResult, error in
                self.hideProgressHUD()
                print("Auth Result google signin : ", authResult)
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    self.showAlert(message: error.localizedDescription)
                } else {
                    if let user = authResult?.user {
                        if self.rememberMeSwitchButton.isOn {
                            MyUserDefaults.setRememberMe(true)
                        }
                        
                        // Save user data under the user ID
                        let userData: [String: Any] = [
                            "name": user.displayName ?? "",
                            "email": user.email ?? "",
                            "userDescription": "",
                            "admin": true,
                            "userId": user.uid,
                        ]
                        
                        let databaseRef = Database.database().reference()
                        let user = User(name: user.displayName ?? "", email: authResult?.user.email ?? "", userDescription: user.description, userId: user.uid)

                        guard let uid = authResult?.user.uid else {
                            return
                        }
                        
                        databaseRef.child("users").child(uid).updateChildValues(userData) { (error, ref) in
                            if let error = error {
                                print("An error occurred while saving user data: \(error.localizedDescription)")
                            } else {
                                print("User data saved successfully!")
                            }
                        }

                        
                        AppController.shared.user = user
                        self.getUserFromDB(email: authResult?.user.email ?? "")
                    }
                }
            }
        }
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
                if let user = authResult?.user {
                    if self.rememberMeSwitchButton.isOn {
                        MyUserDefaults.setRememberMe(true)
                    }
                    let user = User(name: user.displayName ?? "", email: self.emailTextField.text!, userDescription: user.description, userId: user.uid)
                    AppController.shared.user = user
                    self.getUserFromDB(email: self.emailTextField.text!)
                }
            }
        }
    }
    
    private func getUserFromDB(email: String) {
        let databaseRef = Database.database().reference()

        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("User not found")
                self.navigateToHome()
                return
            }

            for case let child as DataSnapshot in snapshot.children {
                guard let userData = child.value as? [String: Any] else {
                    print("Error: Could not parse user data")
                    return
                }

                print("User data: \(userData)")
                
                if let isAdmin = userData["admin"] as? Bool {
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
    
    //MARK: - Google Signin
    
}
