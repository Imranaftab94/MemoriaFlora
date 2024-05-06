//
//  ImageSelectionAlertViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation

import UIKit
import AVKit

class ImageSelectionAlertViewController: NSObject {
    
    private let controller: UIViewController
    private let sender: UIView
    private var alertController: UIAlertController?
    private var isEditable: Bool = false
    
    var onImageSelected: ((_ image: UIImage?) -> Void)?
    var onVideoSelected: ((_ url: URL?) -> ())?
    
    init(sender: UIView, viewController: UIViewController, isEditable: Bool = false) {
        self.controller = viewController
        self.sender = sender
        self.isEditable = isEditable
    }
    
    func present() {
        if alertController == nil {
            alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            alertController?.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                                
                if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                    let alert = UIAlertController(title: "Alert", message: "Please give access to camera from settings", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.controller.present(alert, animated: true, completion: nil)
                } else {
                    self.openCamera(presentationStyle: .overFullScreen, isEditable: self.isEditable)
                }
            }))
            
            alertController?.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                
                
                self.openMediaLibrary(presentationStyle: .overFullScreen, isEditable: self.isEditable)
            }))
            
            alertController?.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:{ _ in
            }))
            
            
            if let presenter = alertController?.popoverPresentationController {
                presenter.sourceView = sender
                presenter.sourceRect = sender.bounds
            }
        }
        
        if let alertController = alertController {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
    func openMediaLibrary(openForImageAndVideo: Bool = false) {
        self.openMediaLibrary(presentationStyle: .overFullScreen, openForImageAndVideo: openForImageAndVideo)
    }
    
    /// Helper method to open media library, it creates a picker controller, assigns `viewController` as a delegate and then later on presents it. It also returns `UIImagePickerController` for you to override its delegate method if you want. By default, it assigns `viewController` as its delegate. If you do not need return value then just discard it.
    private func openMediaLibrary(presentationStyle: UIModalPresentationStyle, openForImageAndVideo: Bool = false, isEditable: Bool = false) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = isEditable
            
            if openForImageAndVideo {
                imagePicker.mediaTypes = ["public.image", "public.movie"]
            } else {
                imagePicker.mediaTypes = ["public.image"]
            }
            
            imagePicker.modalPresentationStyle = presentationStyle
            
            
            self.controller.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Helper method to open camera, it creates a picker controller, assigns `viewController` as a delegate and then later on presents it. It also returns `UIImagePickerController` for you to override its delegate method if you want. By default, it assigns `viewController` as its delegate. If you do not need return value then just discard it.
    private func openCamera(presentationStyle: UIModalPresentationStyle, isEditable: Bool = false) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    let imagePicker = UIImagePickerController()
                    
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = isEditable
                    imagePicker.modalPresentationStyle = presentationStyle
                    
                    DispatchQueue.main.async {
                        self.controller.present(imagePicker, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Camera Access", message: "Please allow access to camera from settings.", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                        DispatchQueue.main.async {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.controller.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ImageSelectionAlertViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if isEditable {
            selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        } else {
            selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        
        if let image = selectedImage, let imageData = image.jpeg(.lowest) {
            selectedImage = UIImage(data: imageData)
        }
        
        self.onImageSelected?(selectedImage)
        self.onVideoSelected?(videoURL)
        
        self.controller.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.controller.dismiss(animated: true, completion:nil)
    }
}
