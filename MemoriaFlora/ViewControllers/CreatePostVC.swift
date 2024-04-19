//
//  CreatePostVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit

class CreatePostVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userImageView: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var userNameContainer: UIView!
    
    private var imageSelectionAlertViewController: ImageSelectionAlertViewController?
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.setNavigationBackButtonColor()
        self.title = "Create Post"
        self.configureTextFields()
    }
    
    @IBAction func onClickPickImageButton(_ sender: UIButton) {
        imageSelectionAlertViewController = ImageSelectionAlertViewController(sender: sender, viewController: self)
        imageSelectionAlertViewController?.onImageSelected = { (image) in
            if let image = image {
                self.userProfileImage.image = image
            }
        }
        
        imageSelectionAlertViewController?.onVideoSelected = { (video) in
            if let video = video {
                do {
                    let videoData = try Data(contentsOf: video)
                    
                } catch {
                    print("Unable to load data: \(error)")
                }
                
            }
        }
        imageSelectionAlertViewController?.openMediaLibrary(openForImageAndVideo: true)
    }
    
    @IBAction func onClickShareMemoryButton(_ sender: UIButton) {
        
    }
    
    private func configureTextFields() {
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#707070")])
        userNameTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Set delegates
        userNameTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Set initial border colors
        userNameContainer.layer.borderColor = UIColor.black.cgColor
        userNameContainer.layer.borderWidth = 1.0
        
        descriptionContainer.layer.borderColor = UIColor.black.cgColor
        descriptionContainer.layer.borderWidth = 1.0
    }
    
    private func configureViews() {
        self.containerView.layer.cornerRadius = 16
        self.containerView.layer.masksToBounds = true
        
        self.userImageView.layer.cornerRadius = 16
        self.userImageView.layer.masksToBounds = true
        
        self.userNameContainer.layer.cornerRadius = 16
        self.userNameContainer.layer.masksToBounds = true
        
        self.descriptionContainer.layer.cornerRadius = 16
        self.descriptionContainer.layer.masksToBounds = true
        
        self.userProfileImage.layer.cornerRadius = 16
        self.userProfileImage.layer.masksToBounds = true
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTextField {
            // Change border color of username container
            userNameContainer.layer.borderColor = activeBorderColor.cgColor
            userNameContainer.layer.borderWidth = 2.0
            
            // Reset border color of description container
            descriptionContainer.layer.borderColor = inactiveBorderColor.cgColor
            descriptionContainer.layer.borderWidth = 1.0
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            // Change border color of description container
            descriptionContainer.layer.borderColor = activeBorderColor.cgColor
            descriptionContainer.layer.borderWidth = 2.0
            
            // Reset border color of username container
            userNameContainer.layer.borderColor = inactiveBorderColor.cgColor
            userNameContainer.layer.borderWidth = 1.0
        }
    }
}
