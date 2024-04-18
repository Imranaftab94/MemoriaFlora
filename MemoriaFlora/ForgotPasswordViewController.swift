//
//  ForgotPasswordViewController.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func ForgotPasswordTapped(_ sender: UIButton) {
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
