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
    @IBOutlet weak var flowerImageView: UIImageView!
    
    @IBOutlet weak var updateFlower: UIButton!
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    private var imageSelectionAlertViewController: ImageSelectionAlertViewController?
    private var selectedImage: UIImage?
    
    var flowerToupdate: FlowerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Update Flower".localized()
        self.setNavigationBackButtonColor()
        
        self.configureViews()
        self.configureTextFields()
        self.updateFlower.setTitle("Update Flower".localized(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    class func instantiate(flowerToUpdate: FlowerModel) -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Flowers)
        vc.flowerToupdate = flowerToUpdate
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
        imageSelectionAlertViewController?.openMediaLibrary(openForImageAndVideo: true)
    }
    
    @IBAction func onClickUpdateButton(_ sender: UIButton) {
        guard let category = self.flowerToupdate?.category else { return }
        guard let flowerId = self.flowerToupdate?.flowerId else { return }
        guard let imageUrl = self.flowerToupdate?.imageUrl else { return }
        
        guard let price = priceTextField.text, !price.isEmpty else {
            showAlert(message: "Please enter price to update".localized())
            return
        }
        
        guard let image = selectedImage else {
            updateValues(price: price, imageUrl: imageUrl, category: category, flowerId: flowerId)
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            showAlert(message: "Failed to convert image to data".localized())
            return
        }
        
        let storageRef = Storage.storage().reference().child("flowers").child(flowerId)
        
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
                
                self.updateValues(price: price, imageUrl: downloadURL.absoluteString, category: category, flowerId: flowerId)
            }
        }
    }
    
    private func updateValues(price: String, imageUrl: String, category: String, flowerId: String) {
        let timestamp = Date().timeIntervalSince1970
        
        let memoryData: [String: Any] = [
            "flowerPrice": price,
            "imageUrl": imageUrl,
            "timestamp": timestamp
        ]
        
        // Save memory data in the Realtime Database
        Database.database().reference().child("flowers").child(category).child(flowerId).updateChildValues(memoryData) { (error, ref) in
            if let error = error {
                print("Error saving memory data: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Flowers data updated successfully!, Remember to adjust the item price on the app store to ensure accurate reflection within the app".localized(), title: "Alert".localized(), action: UIAlertAction(title: "OK".localized(), style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
            }
        }
    }
}

extension UpdateFlowerVC: UITextFieldDelegate {
    private func configureTextFields() {
        priceTextField.attributedPlaceholder = NSAttributedString(string: "Enter price here".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#707070")])
        
        priceTextField.delegate = self
        priceContainerView.layer.borderColor = UIColor.black.cgColor
        priceContainerView.layer.borderWidth = 1.0
    }
    
    private func configureViews() {
        self.priceContainerView.layer.cornerRadius = 16
        self.priceContainerView.layer.masksToBounds = true
        
        if let flower = flowerToupdate {
            self.priceTextField.text = flower.flowerPrice ?? ""
            if let url = URL(string: flower.imageUrl ?? "") {
                self.flowerImageView.kf.setImage(with: url)
            }
        }
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
