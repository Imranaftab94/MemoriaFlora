//
//  CreatePostVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CreatePostVC: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var demiseContainerView: UIView!
    @IBOutlet weak var demiseTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userImageView: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var userNameContainer: UIView!
    
    private var imageSelectionAlertViewController: ImageSelectionAlertViewController?
    private var selectedImage: UIImage?
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.setNavigationBackButtonColor()
        self.title = "Create Post"
        self.configureTextFields()
        self.configureDatePicker()
    }
    
    private func configureDatePicker() {
        // Set the delegate of the text field to self
        demiseTextField.delegate = self
        
        // Configure the date picker mode
        datePicker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            
        }
        
        // Assign the date picker as the input view of the text field
        demiseTextField.inputView = datePicker
        
        // Add a toolbar with a done button above the date picker
        addDoneButtonToDatePicker()
        
        // Add a target to detect changes in the date picker's value
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // Function to add a toolbar with a done button above the date picker
    func addDoneButtonToDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        
        demiseTextField.inputAccessoryView = toolbar
    }
    
    // Function called when the done button is tapped
    @objc func doneButtonTapped() {
        demiseTextField.resignFirstResponder()
    }
    
    // Function called when the date picker's value changes
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        demiseTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func onClickPickImageButton(_ sender: UIButton) {
        imageSelectionAlertViewController = ImageSelectionAlertViewController(sender: sender, viewController: self)
        imageSelectionAlertViewController?.onImageSelected = { (image) in
            if let image = image {
                self.userProfileImage.image = image
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
    
    @IBAction func onClickShareMemoryButton(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not logged in")
            return
        }
        
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            showAlert(message: "Please enter name")
            return
        }
        
        guard let demiseTF = demiseTextField.text, !demiseTF.isEmpty, description != "" else {
            showAlert(message: "Please enter Date of Demise")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty, description != "" else {
            showAlert(message: "Please enter description")
            return
        }
        
        guard let image = selectedImage else {
            showAlert(message: "Please select a picture")
            return
        }
        
        // Convert image to Data
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            showAlert(message: "Failed to convert image to data")
            return
        }
        
        // Create a unique key for the memory
        let memoryKey = Database.database().reference().child("memories").childByAutoId().key ?? ""
        
        // Reference to the storage
        let storageRef = Storage.storage().reference().child("memories").child(memoryKey)
        
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
                
                let timestamp = Date().timeIntervalSince1970
                
                let id = UUID().uuidString
                guard let email = AppController.shared.user?.email else { return }
                guard let id = AppController.shared.user?.userId else { return }
                
                let memoryData: [String: Any] = [
                    "id": id,
                    "userName": userName,
                    "description": description,
                    "imageUrl": downloadURL.absoluteString,
                    "demiseDate": demiseTF,
                    "timestamps": timestamp,
                    "condolences": 0,
                    "memoryId": memoryKey,
                    "createdByEmail": email,
                    "createdById": id
                ]
                
                // Save memory data in the Realtime Database
                Database.database().reference().child("memories").child(memoryKey).setValue(memoryData) { (error, ref) in
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
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Upload failed: \(error.localizedDescription)")
                // Notify user about the failure
                self.showAlert(message: "Upload failed. Please try again.")
            }
        }
    }
    
    private func configureTextFields() {
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#707070")])
        
        demiseTextField.attributedPlaceholder = NSAttributedString(string: "Date Of Demise", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#707070")])
        
        userNameTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Set delegates
        userNameTextField.delegate = self
        descriptionTextView.delegate = self
        demiseTextField.delegate = self
        
        // Set initial border colors
        userNameContainer.layer.borderColor = UIColor.black.cgColor
        userNameContainer.layer.borderWidth = 1.0
        
        descriptionContainer.layer.borderColor = UIColor.black.cgColor
        descriptionContainer.layer.borderWidth = 1.0
        
        self.demiseContainerView.layer.borderColor = UIColor.black.cgColor
        self.demiseContainerView.layer.borderWidth = 1.0
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
        
        self.demiseContainerView.layer.cornerRadius = 16
        self.demiseContainerView.layer.masksToBounds = true
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTextField {
            // Change border color of username container
            userNameContainer.layer.borderColor = activeBorderColor.cgColor
            userNameContainer.layer.borderWidth = 2.0
            
            // Reset border color of description container
            descriptionContainer.layer.borderColor = inactiveBorderColor.cgColor
            descriptionContainer.layer.borderWidth = 1.0
            
            demiseContainerView.layer.borderColor = inactiveBorderColor.cgColor
            demiseContainerView.layer.borderWidth = 1.0
        } else if textField == demiseTextField {
            // Change border color of username container
            userNameContainer.layer.borderColor = inactiveBorderColor.cgColor
            userNameContainer.layer.borderWidth = 1.0
            
            // Reset border color of description container
            descriptionContainer.layer.borderColor = inactiveBorderColor.cgColor
            descriptionContainer.layer.borderWidth = 1.0
            
            demiseContainerView.layer.borderColor = activeBorderColor.cgColor
            demiseContainerView.layer.borderWidth = 2.0
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
            
            demiseContainerView.layer.borderColor = inactiveBorderColor.cgColor
            demiseContainerView.layer.borderWidth = 1.0
        }
    }
}
