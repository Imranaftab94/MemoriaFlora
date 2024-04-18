//
//  SignupViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signupTapped(_ sender: UIButton) {
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)

    }
    
}
