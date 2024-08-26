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
import CryptoKit
import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var rememberMeSwitchButton: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var createAnAccount: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.localized()
    }
    
    private func configureViews() {
        let text = "Caro Estinto uses cookies for analytics, personalized contents and ads, using Caro Estinto's service you agree with Policy and Rules.".localized()
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let policyRange = (text as NSString).range(of: "Policy".localized())
        let rulesRange = (text as NSString).range(of: "Rules".localized())
        
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
    
    func localized() {
        self.loginButton.setTitle("Login".localized(), for: .normal)
        self.appleButton.setTitle("", for: .normal)
        self.googleButton.setTitle("", for: .normal)
        self.forgotPassword.setTitle("Forgot Password".localized(), for: .normal)
        self.createAnAccount.setTitle("Create an account".localized(), for: .normal)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return true
    }
    
    @IBAction func onClickSwitchButton(_ sender: UISwitch) {
        
    }
    
    @IBAction func onClickFacebookButton(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    @IBAction func onClickFacebookLoginButton(_ sender: UIButton) {
        facebookLogin()
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
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                self.hideProgressHUD()
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    self.showAlert(message: error.localizedDescription)
                    return
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
                            "userId": user.uid,
                        ]
                        
                        let databaseRef = Database.database().reference()
                        let user = User(name: user.displayName ?? "", email: authResult?.user.email ?? "", userDescription: user.description, userId: user.uid)
                        
                        guard let uid = authResult?.user.uid else {
                            return
                        }
                        
                        databaseRef.child(kUusers).child(uid).updateChildValues(userData) { (error, ref) in
                            if let error = error {
                                print("An error occurred while saving user data: \(error.localizedDescription)")
                            } else {
                                print("User data saved successfully!")
                            }
                        }
                        
                        AppController.shared.user = user
                        self.getUserFromDB(userId: authResult?.user.uid ?? "")
                    }
                }
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
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
        
        self.showProgressHUD()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            self.hideProgressHUD()
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.showAlert(message: error.localizedDescription)
                return
            } else {
                if let user = authResult?.user {
                    if self.rememberMeSwitchButton.isOn {
                        MyUserDefaults.setRememberMe(true)
                    }
                    let user = User(name: user.displayName ?? "", email: self.emailTextField.text!, userDescription: user.description, userId: user.uid)
                    AppController.shared.user = user
                    self.getUserFromDB(userId: user.userId ?? "")
                }
            }
        }
    }
    
    private func getUserFromDB(userId: String) {
        let databaseRef = Database.database().reference()
        
        let query = databaseRef.child(kUusers).queryOrdered(byChild: "userId").queryEqual(toValue: userId).queryLimited(toFirst: 1)
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
            let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarController") as! MainTabbarController
            animateTransition(to: homeVC, view: self.view)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert".localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - APPLE SIGNIN

extension LoginViewController : ASAuthorizationControllerDelegate {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Single-sign-on with Apple
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            print(credential)
            self.showProgressHUD()
            Auth.auth().signIn(with: credential) { authResult, error in
                self.hideProgressHUD()
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    self.showAlert(message: error.localizedDescription)
                    return
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
                            "userId": user.uid,
                        ]
                        
                        let databaseRef = Database.database().reference()
                        let user = User(name: user.displayName ?? "", email: authResult?.user.email ?? "", userDescription: user.description, userId: user.uid)
                        
                        guard let uid = authResult?.user.uid else {
                            return
                        }
                        
                        databaseRef.child(kUusers).child(uid).updateChildValues(userData) { (error, ref) in
                            if let error = error {
                                print("An error occurred while saving user data: \(error.localizedDescription)")
                            } else {
                                print("User data saved successfully!")
                            }
                        }
                        
                        
                        AppController.shared.user = user
                        self.getUserFromDB(userId: authResult?.user.uid ?? "")
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController {
    func facebookLogin() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                // Handle login error here
                print("Error: \(error.localizedDescription)")
            } else if let result = result, !result.isCancelled {
                // Login successful, you can access the user's Facebook data here
                self.fetchFacebookUserData()
            } else {
                // Login was canceled by the user
                print("Login was cancelled.")
            }
        }
    }
    // MARK: - Fetch Facebook User Data
    
    func fetchFacebookUserData() {
        if AccessToken.current != nil {
            // You can make a Graph API request here to fetch user data
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
                if let error = error {
                    // Handle API request error here
                    print("Error: \(error.localizedDescription)")
                } else if let userData = result as? [String: Any] {
                    // Access the user data here
                    let userID = userData["id"] as? String
                    let name = userData["name"] as? String
                    
                    // Handle the user data as needed
                    print("User: \(userData)")
                    print("User ID: \(userID ?? "")")
                    print("Name: \(name ?? "")")
                }
            }
        } else {
            print("No active Facebook access token.")
        }
    }
}
