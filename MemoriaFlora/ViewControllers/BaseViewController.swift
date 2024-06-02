//
//  BaseViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit

class BaseViewController: UIViewController {

    var progressHUD: ProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showProgressHUD(text: String = "Loading") {
        DispatchQueue.main.async {
            if let progressHUD = self.progressHUD {
                progressHUD.removeFromSuperview()
                self.progressHUD = nil
            }
            
            self.view.isUserInteractionEnabled = false
            self.progressHUD = ProgressHUD(text: text.localized())
            self.view.addSubview(self.progressHUD!)
        }
    }
    
    func hideProgressHUD() {
        DispatchQueue.main.async {
            guard let progressHUD = self.progressHUD else { return }
            
            self.view.isUserInteractionEnabled = true
            progressHUD.removeFromSuperview()
            self.progressHUD = nil
        }
    }
    
    func showAlert(message: String, title: String? = nil, action: UIAlertAction? = nil, secondAction: UIAlertAction? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alertController = UIAlertController(title: title?.localized(),
                                                    message: message.localized(),
                                                    preferredStyle: .alert)
            
            alertController.addAction(action ?? UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
            
            if let secondAction = secondAction {
                alertController.addAction(secondAction)
            }
                        
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
