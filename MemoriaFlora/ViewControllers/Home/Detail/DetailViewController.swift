//
//  DetailViewController.swift
//  Caro Estinto
//
//  Created by ImranAftab on 4/20/24.
//

import UIKit
import FirebaseDynamicLinks
import Kingfisher

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var demiseLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var memory: Memory?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButtonColor()
        config()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            self.animate()
        }
    }
    
    @IBAction func chooseFlowerButtonTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = FlowersVC.instantiate(fromAppStoryboard: .Flowers)
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
