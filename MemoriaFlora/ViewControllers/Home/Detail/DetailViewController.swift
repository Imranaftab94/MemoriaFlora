//
//  DetailViewController.swift
//  Caro Estinto
//
//  Created by ImranAftab on 4/20/24.
//

import UIKit
import FirebaseDynamicLinks
import Kingfisher
import FirebaseDatabase

class DetailViewController: BaseViewController {
    @IBOutlet weak var condolencesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var demiseLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var memory: Memory?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButtonColor()
        
        if let id = self.memory?.uid {
            observeMemory(withId: id)
        }
    }
    
    @IBAction func chooseFlowerButtonTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = FlowersVC.instantiate(fromAppStoryboard: .Flowers)
            vc.onSelectPayment = { [weak self] (category, flower) in
                guard let self = self else { return }
                self.addCondolences()
                print(category, flower)
                animate(category.flowerType)
            }
            let navigationVC = UINavigationController.init(rootViewController: vc)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        
        guard let uid = memory?.uid else { return }
        guard let link = URL(string: "https://memoriaflora.page.link?id=\(uid)") else { return }
        let dynamicLinksDomain = "https://memoriaflora.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain)//DynamicLinkComponents(link: link, domain: dynamicLinksDomain)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.MemoriaFlora.App")
        linkBuilder?.iOSParameters?.appStoreID = "6499025659"

        linkBuilder?.shorten { (shortURL, _, error) in
            if let error = error {
                print("Error creating dynamic link: \(error.localizedDescription)")
                return
            }
            if let shortURL = shortURL {
                print("Short URL: \(shortURL)")
                self.presentSharesSheet(link: "\(shortURL)")
                // Share or use the short URL as needed
            }
        }
    }
    
    @IBAction func goToProfileTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    private func observeMemory(withId id: String) {
        // Reference to the memories node for the user
        let memoriesRef = Database.database().reference().child("memories")
        
        // Create a query to find the memory with the specified ID
        let memoryQuery = memoriesRef.queryOrdered(byChild: "id").queryEqual(toValue: id)
        
        // Observe for changes in memories
        
        self.showProgressHUD()
        memoryQuery.observeSingleEvent(of: .value) { (snapshot) in
            self.hideProgressHUD()
            
            guard let memoryData = snapshot.value as? [String: Any] else {
                return
            }
            
            guard let value = memoryData.first?.value as? [String: Any] else { return }
            
            let memory = Memory.createMemory(from: value)
            self.memory = memory
            self.config()
            
            self.observeMemoryChanges(withId: id)
        }
    }
    
    private func observeMemoryChanges(withId id: String) {
        // Reference to the memories node for the user
        let memoriesRef = Database.database().reference().child("memories")
        
        // Create a query to find the memory with the specified ID
        let memoryQuery = memoriesRef.queryOrdered(byChild: "id").queryEqual(toValue: id)
        
        // Observe for changes in the memory
        memoryQuery.observe(.childChanged) { (snapshot) in
            guard let memoryData = snapshot.value as? [String: Any] else {
                // Handle if memory data is not available
                return
            }
            
            let memory = Memory.createMemory(from: memoryData)
            
            self.memory = memory
            
            self.config()
        }
    }
    
    //MARK: - FUNCTIONS
    
    func presentSharesSheet(link : String) {
        let text = "🌹 In loving memory of \(nameLabel.text ?? ""), let's honor their memory together. Please join me in paying tribute by offering flowers. \n\(link) \n#InMemory #ForeverInOurHearts 🌹"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func config() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.memory?.userName ?? ""
            self.detailLabel.text = self.memory?.description ?? ""
            self.demiseLabel.text = "Date of Demise: \(self.memory?.dateOfDemise ?? "")"
            if let url = URL(string: self.memory?.imageUrl ?? "") {
                self.imgView.kf.setImage(with: url)
            }
            if self.memory?.condolences == 0 {
                self.condolencesLabel.isHidden = true
            } else {
                self.condolencesLabel.isHidden = false
                self.condolencesLabel.text = "Condolences: \(self.memory?.condolences ?? 0)"
            }
        }
    }
    
    private func addCondolences() {
        let memoriesRef = Database.database().reference().child("memories")
        
        guard let id = self.memory?.uid else { return }
        // Create a query to find the memory with the specified ID
        let memoryQuery = memoriesRef.queryOrdered(byChild: "id").queryEqual(toValue: id)
        
        // Fetch the memory with the specified ID
        memoryQuery.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists(), let memorySnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  var memoryData = memorySnapshot.value as? [String: Any] else {
                print("Memory with ID \(id) not found.")
                return
            }
            
            guard let currentCondolences = memoryData["condolences"] as? Int else {
                print("Failed to fetch condolences value.")
                return
            }
            
            // Increment condolences by 1
            let updatedCondolences = currentCondolences + 1
            
            // Update condolences value in memory data
            memoryData["condolences"] = updatedCondolences
            
            // Update only the "condolences" variable in the memory node
            memorySnapshot.ref.updateChildValues(["condolences": updatedCondolences]) { (error, ref) in
                if let error = error {
                    print("Error updating condolences: \(error.localizedDescription)")
                } else {
                    print("Condolences updated successfully!")
                    // Show alert or perform other actions if needed
                }
            }
        }
    }
    
    private func setNavigationBackButtonColor() {
        self.title = "Pay Tribute"
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }

    func animate(_ img: String) {
        
        let numberOfFlowers = 30 // Adjust as needed
        let flowerImageNames = [img] // Names of your flower images
        
        for index in 0..<numberOfFlowers {
            let randomIndex = Int.random(in: 0..<flowerImageNames.count)
            let imageName = flowerImageNames[randomIndex]
            let imageView = UIImageView(image: UIImage(named: imageName))
            let delay = TimeInterval(index) * 0.2 // Adjust the delay as needed (e.g., 0.2 seconds between each flower)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                imageView.frame = CGRect(x: CGFloat.random(in: 0..<self.containerView.bounds.width),
                                         y: self.containerView.bounds.height,
                                         width: 50, height: 50) // Adjust size as needed
                self.containerView.addSubview(imageView)
                
                // Add rotation animation
                let rotationAngle = CGFloat.random(in: -CGFloat.pi...CGFloat.pi)
                imageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                
                UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseInOut, animations: {
                    imageView.frame.origin.y = -imageView.frame.height
                    imageView.transform = .identity // Reset rotation
                    imageView.alpha = 0.0 // Fade out
                }, completion: { _ in
                    imageView.removeFromSuperview() // Remove the flower image after animation completes
                })
            }
        }

    }
    
}
