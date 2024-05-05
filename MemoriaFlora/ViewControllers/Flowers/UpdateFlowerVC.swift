//
//  UpdateFlowerVC.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 05/05/2024.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class UpdateFlowerVC: BaseViewController {
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    private var imageSelectionAlertViewController: ImageSelectionAlertViewController?
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Update Flower"
        self.setNavigationBackButtonColor()
        
        self.configureViews()
        self.configureTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    class func instantiate() -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Flowers)
        return vc
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    @IBAction func onClickImageButton(_ sender: UIButton) {
        imageSelectionAlertViewController = ImageSelectionAlertViewController(sender: sender, viewController: self)
        imageSelectionAlertViewController?.onImageSelected = { (image) in
            if let image = image {
                self.flowerImageView.image = image
                self.selectedImage = image
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
    
    @IBAction func onClickUpdateButton(_ sender: UIButton) {
        guard let price = priceTextField.text, !price.isEmpty else {
            showAlert(message: "Please enter price to update")
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter name to update")
            return
        }
        
        guard let image = selectedImage else {
            showAlert(message: "Please select a picture to update")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            showAlert(message: "Failed to convert image to data")
            return
        }
        
        let storageRef = Storage.storage().reference().child("flowers")
        
        // Upload image data to the storage
        self.showProgressHUD()
        let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            self.hideProgressHUD()
            guard let _ = metadata else {
                // Handle error
                print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }
                
                let memoryData: [String: Any] = [
                    "flowerName": name,
                    "flowerPrice": price,
                    "imageUrl": downloadURL.absoluteString,
                    "category": "Lilies",
                    "timestamp": ""
                ]
                
                // Save memory data in the Realtime Database
                Database.database().reference().child("flowers").child("Lilies").setValue(memoryData) { (error, ref) in
                    if let error = error {
                        print("Error saving memory data: \(error.localizedDescription)")
                    } else {
                        print("Memory data saved successfully!")
                        self.showAlert(message: "Posted successfully", title: "Alert", action: UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.navigationController?.popViewController(animated: true)
                        }))
                    }
                }
            }
        }
    }
    
    private func createFlower() {
        
    }
}

extension UpdateFlowerVC: UITextFieldDelegate {
    private func configureTextFields() {
        priceTextField.attributedPlaceholder = NSAttributedString(string: "Enter price here", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#707070")])
        
        priceTextField.delegate = self
        priceContainerView.layer.borderColor = UIColor.black.cgColor
        priceContainerView.layer.borderWidth = 1.0
    }
    
    private func configureViews() {
        self.priceContainerView.layer.cornerRadius = 16
        self.priceContainerView.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        priceContainerView.layer.borderColor = activeBorderColor.cgColor
        priceContainerView.layer.borderWidth = 2.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        priceContainerView.layer.borderColor = inactiveBorderColor.cgColor
        priceContainerView.layer.borderWidth = 1.0
    }
}
