//
//  ForgotPasswordViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    
    @IBAction func ForgotPasswordTapped(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            if let error = error {
                // An error occurred while sending password reset email
                print("An error occurred during sign-up")
                self.showAlert(message: error.localizedDescription)
            } else {
                // Password reset email sent successfully
                self.showAlert(message: "Reset password email sent successfully")
                print("An email sent")
            }
        }

    }
    @IBAction func loginTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
