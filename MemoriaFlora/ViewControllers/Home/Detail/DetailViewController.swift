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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var demiseLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var memory: Memory?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButtonColor()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            self.animate()
        }
        
        if let id = self.memory?.uid {
            observeMemory(withId: id)
        }
    }
    
    @IBAction func chooseFlowerButtonTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = FlowersVC.instantiate(fromAppStoryboard: .Flowers)
            vc.onSelectPayment = { [weak self] (category, flower) in
                guard let self = self else { return }
                print(category, flower)
            }
            let navigationVC = UINavigationController.init(rootViewController: vc)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        
        guard let link = URL(string: "https://memoriaflora.page.link?id=2") else { return }
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
            
            // Extract the memory data
            guard let memoryDict = memoryData.first?.value as? [String: Any],
                  let uid = memoryDict["id"] as? String,
                  let userName = memoryDict["userName"] as? String,
                  let description = memoryDict["description"] as? String,
                  let imageUrl = memoryDict["imageUrl"] as? String,
                  let dateOfDemise = memoryDict["demiseDate"] as? String,
                  let timestampString = memoryDict["timestamps"] as? TimeInterval else {
                return
            }
            
            let date = Date(timeIntervalSince1970: timestampString)
            // Create Memory object for the memory with the specified ID
            let memory = Memory(uid: uid, userName: userName, description: description, imageUrl: imageUrl, dateOfDemise: dateOfDemise, timestamp: date)
            self.memory = memory
            self.config()
            // Handle the retrieved memory, such as updating UI or performing any other action
            print("User: \(memory.userName), Description: \(memory.description), Image URL: \(memory.imageUrl)")
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
        nameLabel.text = memory?.userName ?? ""
        detailLabel.text = memory?.description ?? ""
        demiseLabel.text = "Date of Demise: \(memory?.dateOfDemise ?? "")"
        if let url = URL(string: memory?.imageUrl ?? "") {
            imgView.kf.setImage(with: url)
        }
    }
    
    private func setNavigationBackButtonColor() {
        self.title = "Pay Tribute"
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }

    func animate() {
        // Add multiple flower images to the view and animate them
        let numberOfFlowers = 10 // Adjust as needed
        let flowerImageNames = ["rose3", "rose3", "rose3"] // Names of your flower images
        
        for _ in 0..<numberOfFlowers {
            let randomIndex = Int.random(in: 0..<flowerImageNames.count)
            let imageName = flowerImageNames[randomIndex]
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.frame = CGRect(x: CGFloat.random(in: 0..<containerView.bounds.width),
                                     y: containerView.bounds.height,
                                     width: 50, height: 50) // Adjust size as needed
            containerView.addSubview(imageView)
            
            UIView.animate(withDuration: 3.0, delay: 0, options: .curveLinear, animations: {
                imageView.frame.origin.y = -imageView.frame.height
            }, completion: { _ in
                imageView.removeFromSuperview() // Remove the flower image after animation completes
            })
        }
    }
    
}
