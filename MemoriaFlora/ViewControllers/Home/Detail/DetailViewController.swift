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
import FirebaseStorage

class DetailViewController: BaseViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var condolencesButton: UIButton!
    @IBOutlet weak var demiseLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var bottomShare: UIButton!
    @IBOutlet weak var topShare: UIButton!
    
    @IBOutlet weak var shareBackground: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    var memory: Memory?
    var condolences: [Condolence] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButtonColor()
        
        if let id = self.memory?.uid {
            observeMemory(withId: id)
        }
        getCondolencesCount()
        self.configureTableView()
        self.getCondolences()
        self.observeCondolences()
        topShare.setTitle("", for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        shareBackground.layer.cornerRadius = 8
        shareBackground.layer.masksToBounds = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        MyUserDefaults.setDynamicLink(nil)
    }
    
    @IBAction func onClickCondolencesButton(_ sender: UIButton) {
        guard let memory = memory else { return }
        self.navigationController?.pushViewController(CondolenceVC.instantiate(memory: memory), animated: true)
    }
    
    @IBAction func chooseFlowerButtonTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = FlowersVC.instantiate(memory: self.memory!)
            vc.onSelectPayment = { [weak self] (category, flower) in
                guard let self = self else { return }
                self.createCondolence(category: category, flower: flower)
                animate(category.categoryName ?? "")
            }
            let navigationVC = UINavigationController.init(rootViewController: vc)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        
        guard let uid = memory?.uid else { return }
        guard let memoryKey = memory?.memoryKey else { return }
        guard let encodedUid = uid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedMemoryKey = memoryKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let link = URL(string: "https://memoriaflora.page.link?id=\(encodedUid)&memoryKey=\(encodedMemoryKey)") else { return }
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
    
    // API CALL TO FETCH DETAILS
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
    
    // API CALL TO OBSERVE CHILD UPDATES OR CHANGES
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
        }
    }
    
    private func getCondolencesCount() {
//        let databaseRef = Database.database().reference()
//        guard let memoryId = self.memory?.memoryKey else { return }
//        databaseRef.child("condolences").child(memoryId).observe(.value) { (snapshot) in
//            let count = snapshot.childrenCount
//            self.condolencesButton.setTitle("Condolences \(count)", for: .normal)
//        }
    }
    
    private func createCondolence(category: FlowerCategoryModel, flower: FlowerModel) {
        guard let memoryId = self.memory?.memoryKey else { return }
        
        let condolenceId = Database.database().reference().child("condolences").child(memoryId).childByAutoId().key ?? ""
        
        guard let userId = AppController.shared.user?.userId else { return }
        
        let timestamp = Date().timeIntervalSince1970
        
        guard let flowerImageUrl = flower.imageUrl else { return }
        
        let condolenceData: [String: Any] = [
            "userId": userId,
            "memoryId": memoryId,
            "timestamp": timestamp,
            "flowerPrice": flower.flowerPrice ?? "",
            "flowerType": category.categoryName ?? "",
            "flowerName": flower.flowerName ?? "",
            "flowerImageUrl": flowerImageUrl
        ]
        
        // Save condolence data in the Realtime Database
        Database.database().reference().child("condolences").child(memoryId).child(condolenceId).setValue(condolenceData) { [weak self] (error, ref) in
            guard let self = self else { return }
            if let error = error {
                print("Error saving condolence data: \(error.localizedDescription)")
            } else {
                print("Condolence data saved successfully!")
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
    
    private func getCondolences() {
        guard let memoryId = self.memory?.memoryKey, !memoryId.isEmpty else {
            return
        }

        self.showProgressHUD()
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child("condolences").child(memoryId).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("No condolences found for memory ID: \(memoryId)")
                self.hideProgressHUD()
                return
            }
            
            var condolences: [Condolence] = []
            let dispatchGroup = DispatchGroup()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let condolenceData = childSnapshot.value as? [String: Any] {
                    var condolence = Condolence.makeCondolence(condolenceData: condolenceData)
                    
                    dispatchGroup.enter()
                    databaseRef.child("users").child(condolence.userId).observeSingleEvent(of: .value) { (userSnapshot) in
                        defer { dispatchGroup.leave() }
                        guard let userData = userSnapshot.value as? [String: Any] else { return }
                        
                        if let email = userData["email"] as? String,
                           let name = userData["name"] as? String {
                            condolence.userName = name
                            condolence.email = email
                        }
                        condolences.append(condolence)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.hideProgressHUD()
                condolences.sort { $0.timestamp > $1.timestamp }
                self.condolences = condolences
                self.reloadTableView()
            }
        }
    }

    private func observeCondolences() {
        guard let memoryId = self.memory?.memoryKey, !memoryId.isEmpty else {
            return
        }
        
        self.showProgressHUD()
        
        let databaseRef = Database.database().reference()
        
        // Observe child events in the condolences node
        databaseRef.child("condolences").child(memoryId).observe(.childAdded) { (snapshot) in
            guard let condolenceData = snapshot.value as? [String: Any] else { return }
            var condolence = Condolence.makeCondolence(condolenceData: condolenceData)
            
            let userId = condolence.userId
            
            databaseRef.child("users").child(userId).observeSingleEvent(of: .value) { (userSnapshot) in
                guard let userData = userSnapshot.value as? [String: Any],
                      let email = userData["email"] as? String,
                      let name = userData["name"] as? String else { return }
                
                condolence.userName = name
                condolence.email = email
                
                self.condolences.append(condolence)
                self.condolences.sort { $0.timestamp > $1.timestamp }
                self.reloadTableView()
            }
        }
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableViewHeightConstraint.constant = CGFloat(self.condolences.count * 86)
            self.tableView.reloadData()
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CondolenceTableViewCell", bundle: nil), forCellReuseIdentifier: "CondolenceTableViewCell")
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return condolences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CondolenceTableViewCell", for: indexPath) as! CondolenceTableViewCell
        
        let item = condolences[indexPath.row]
        
        if let url = URL(string: item.flowerImageUrl) {
            cell.flowerImageView.kf.setImage(with: url)
        }
        cell.nameLabel.text = item.userName ?? "N/A"
        cell.containerView.layer.cornerRadius = 16
        cell.containerView.layer.masksToBounds = true
        cell.flowerImageView.layer.cornerRadius = 10
        cell.flowerImageView.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
