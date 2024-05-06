//
//  FlowersVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FlowersVC: BaseViewController {
    
    @IBOutlet weak var emptyFlowersLabel: UILabel!
    @IBOutlet weak var flowersCategoryCollectionView: UICollectionView!
    @IBOutlet weak var flowerItemCollectionView: UICollectionView!
    
    var selectedFlowerCategory: FlowerCategoryModel?
    var selectedFlower: FlowerModel?
    var memory: Memory?

    var onSelectPayment: ((_ selectedCategory: FlowerCategoryModel, _ selectedFlower: FlowerModel) -> ())?
    
    var flowerCategories: [FlowerCategoryModel] = []
    
    var lilies: [FlowerModel] = []
    var roses: [FlowerModel] = []
    var orchids: [FlowerModel] = []
    var carnations: [FlowerModel] = []
    
    var flowers: [FlowerModel] = []
    
    var selectedCategoryIndex = -1
    var selectedItemIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.setNavigationBackButtonColor()
        self.fetchFlowers()
        self.fetchFlowerCategories()
        self.observeFlowerChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    private func configureCollectionView() {
        flowersCategoryCollectionView.dataSource = self
        flowersCategoryCollectionView.delegate = self
        flowerItemCollectionView.dataSource = self
        flowerItemCollectionView.delegate = self
        
        flowersCategoryCollectionView.register(UINib(nibName: "FlowersCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FlowersCategoryCell")
        flowerItemCollectionView.register(UINib(nibName: "FlowerItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FlowerItemCell")
    }
    
    class func instantiate(memory: Memory) -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Flowers)
        vc.memory = memory
        return vc
    }
    
    func sendEmail() {
        let user = AppController.shared.user
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username =  "iaftab94uw@gmail.com"     // 送信元のSMTPサーバーのusername（Gmailアドレス）
        smtpSession.password = "iuzpanlwvrdgucwu"       // 送信元のSMTPサーバーのpasword（Gmailパスワード）
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "\(user?.name ?? "user").", mailbox: "\(memory?.createdByEmail ?? "")")]
        builder.header.from = MCOAddress(displayName: "Caro Estinto.", mailbox: "iaftab94uw@gmail.com")
        builder.header.subject = "Condolences Flower Purchase Notification"
        builder.textBody = createCondolencesEmail(recipientName: memory?.createdByName ?? "user", purchaserName: user?.name ?? "a user", flowerName: selectedFlower?.flowerName ?? "flower")
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if let error = error {
                print( "Error sending email: \(String(describing: error))")
            } else {
                print( "Email has been sent successfully")
            }
        }
    }
    
    @IBAction func onClickPurchaseFlowerButton(_ sender: UIButton) {
        guard let category = self.selectedFlowerCategory else {
            self.showAlert(message: "Please select a flower category")
            return
        }
        
        guard let flower = self.selectedFlower else {
            self.showAlert(message: "Please select a flower for condolences")
            return
        }
        
        guard let productId = flower.identifier else { return }
        
        PKIAPHandler.shared.setProductIds(ids: [productId])
        self.showProgressHUD()
        PKIAPHandler.shared.fetchAvailableProducts { products in
            guard let product = products.first else {
                self.showAlert(message: "No products found, Something went wrong")
                self.hideProgressHUD()
                return
            }
            
            
            PKIAPHandler.shared.purchase(product: product) { handlerAlert, product, transaction in
                self.hideProgressHUD()
                if let productID = product?.productIdentifier {
                    guard let selectedCategory = self.selectedFlowerCategory else { return }
                    guard let selectedFlower = self.selectedFlower else { return }
                    self.onSelectPayment?(selectedCategory, selectedFlower)
                    self.sendEmail()
                    self.dismiss(animated: true)
                } else {
                    
                }
            }
        }
    }
    
    private func fetchFlowerCategories() {
        let ref = Database.database().reference().child("flowerscategory")
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            defer {
                dispatchGroup.leave()
            }
            guard let categoriesData = snapshot.value as? [String: [String: Any]] else {
                return
            }
            var categories: [FlowerCategoryModel] = []
            
            for (_, categoryValue) in categoriesData {
                if let categoryName = categoryValue["categoryName"] as? String,
                   let categoryId = categoryValue["categoryId"] as? String,
                   let imageUrl = categoryValue["imageUrl"] as? String {
                    categories.append(FlowerCategoryModel(categoryName: categoryName, categoryId: categoryId, imageUrl: imageUrl))
                }
            }
            self.flowerCategories = categories
            self.reloadCollectionViews()
        } withCancel: { (error) in
            self.showAlert(message: error.localizedDescription)
        }
    }

    private func fetchFlowers() {
        self.showProgressHUD()
        let ref = Database.database().reference().child("flowers")
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            defer {
                dispatchGroup.leave()
            }
            guard let flowersData = snapshot.value as? [String: [String: Any]] else {
                return
            }
            
            var flowers: [FlowerModel] = []
            
            for (_, categoryValue) in flowersData {
                for (_, flowerData) in categoryValue {
                    guard let flowerIdData = flowerData as? [String: Any],
                          let category = flowerIdData["category"] as? String,
                          let flowerId = flowerIdData["flowerId"] as? String,
                          let flowerName = flowerIdData["flowerName"] as? String,
                          let flowerPrice = flowerIdData["flowerPrice"] as? String,
                          let imageUrl = flowerIdData["imageUrl"] as? String,
                          let timestamp = flowerIdData["timestamp"] as? TimeInterval,
                          let categoryId = flowerIdData["categoryId"] as? String,
                          let identifier = flowerIdData["identifier"] as? String else {
                        continue
                    }
                    let flower = FlowerModel(category: category, flowerName: flowerName, flowerPrice: flowerPrice, flowerId: flowerId, imageUrl: imageUrl, timestamp: timestamp, categoryId: categoryId, identifier: identifier)
                    
                    flowers.append(flower)
                }
            }
            
            self.roses = flowers.filter { $0.category == "Roses" }
            self.orchids = flowers.filter { $0.category == "Orchids" }
            self.carnations = flowers.filter { $0.category == "Carnations" }
            self.lilies = flowers.filter { $0.category == "Lilies" }
            self.flowerItemCollectionView.reloadData()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.reloadCollectionViews()
            self.hideProgressHUD()
        }
    }
    
    private func observeFlowerChanges() {
        let ref = Database.database().reference().child("flowers")
        
        ref.observe(.value) { snapshot in
            guard let flowersData = snapshot.value as? [String: [String: Any]] else {
                return
            }
            
            var updatedFlowers: [FlowerModel] = []
            
            for (_, categoryValue) in flowersData {
                for (_, flowerData) in categoryValue {
                    guard let flowerIdData = flowerData as? [String: Any],
                          let category = flowerIdData["category"] as? String,
                          let flowerId = flowerIdData["flowerId"] as? String,
                          let flowerName = flowerIdData["flowerName"] as? String,
                          let flowerPrice = flowerIdData["flowerPrice"] as? String,
                          let imageUrl = flowerIdData["imageUrl"] as? String,
                          let timestamp = flowerIdData["timestamp"] as? TimeInterval,
                          let categoryId = flowerIdData["categoryId"] as? String,
                          let identifier = flowerIdData["identifier"] as? String else {
                        continue
                    }
                    
                    let flower = FlowerModel(category: category, flowerName: flowerName, flowerPrice: flowerPrice, flowerId: flowerId, imageUrl: imageUrl, timestamp: timestamp, categoryId: categoryId, identifier: identifier)
                    
                    updatedFlowers.append(flower)
                }
            }
            
            self.roses = updatedFlowers.filter { $0.category == "Roses" }
            self.orchids = updatedFlowers.filter { $0.category == "Orchids" }
            self.carnations = updatedFlowers.filter { $0.category == "Carnations" }
            self.lilies = updatedFlowers.filter { $0.category == "Lilies" }
            
            if self.selectedFlowerCategory?.categoryName == "Lilies" {
                self.flowers = self.lilies
            } else if self.selectedFlowerCategory?.categoryName == "Roses" {
                self.flowers = self.roses
            } else if self.selectedFlowerCategory?.categoryName == "Carnations" {
                self.flowers = self.carnations
            } else if self.selectedFlowerCategory?.categoryName == "Orchids" {
                self.flowers = self.orchids
            }
            self.reloadCollectionViews()
        }
    }
}


extension FlowersVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func reloadCollectionViews() {
        DispatchQueue.main.async {
            if self.flowers.count == 0 {
                self.emptyFlowersLabel.isHidden = false
            } else {
                self.emptyFlowersLabel.isHidden = true
            }
            self.flowerItemCollectionView.reloadData()
            self.flowersCategoryCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == flowersCategoryCollectionView {
            return flowerCategories.count
        } else {
            return flowers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == flowersCategoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowersCategoryCell", for: indexPath) as! FlowersCategoryCollectionViewCell
            cell.containerView.layer.cornerRadius = 16
            cell.containerView.layer.masksToBounds = true
            
            cell.containerView.layer.cornerRadius = 16
            cell.containerView.layer.masksToBounds = true
            
            if selectedCategoryIndex == indexPath.item {
                cell.containerView.layer.borderWidth = 2.0
                cell.containerView.layer.borderColor = UIColor(hexString: "#865EE2").cgColor
            } else {
                cell.containerView.layer.borderWidth = 0.0
            }
            
            let category = flowerCategories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryName
            if let url = URL(string: category.imageUrl ?? "") {
                cell.categoryImageView.kf.setImage(with: url)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowerItemCell", for: indexPath) as! FlowerItemCollectionViewCell
            cell.containerView.layer.cornerRadius = 16
            cell.containerView.layer.masksToBounds = true
            
            cell.flowerImageView.layer.cornerRadius = 16
            cell.flowerImageView.layer.masksToBounds = true
            
            if selectedItemIndex == indexPath.item {
                cell.containerView.layer.borderWidth = 2.0
                cell.containerView.layer.borderColor = UIColor(hexString: "#865EE2").cgColor
            } else {
                cell.containerView.layer.borderWidth = 0.0
            }
            
            let flower = flowers[indexPath.row]
            
            cell.flowerNameLabel.text = flower.flowerName
            cell.flowerPriceLabel.text = "$\(flower.flowerPrice ?? "")"
            if let url = URL(string: flower.imageUrl ?? "") {
                cell.flowerImageView.kf.setImage(with: url)
            }
            if AppController.shared.user?.admin ?? false {
                cell.editButtonView.isHidden = false
                cell.editButtonView.layer.cornerRadius = 12.5
                cell.editButtonView.layer.masksToBounds = true
            } else {
                cell.editButtonView.isHidden = true
                cell.editButtonView.layer.cornerRadius = 12.5
                cell.editButtonView.layer.masksToBounds = true
            }
            
            cell.onClickEditButton = {
                self.navigationController?.pushViewController(UpdateFlowerVC.instantiate(flowerToUpdate: flower), animated: true)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == flowersCategoryCollectionView {
            let flowerCategory = flowerCategories[indexPath.row]
            self.selectedFlowerCategory = flowerCategory
            
            selectedCategoryIndex = indexPath.item
            if flowerCategory.categoryName == "Lilies" {
                self.flowers = lilies
            } else if flowerCategory.categoryName == "Roses" {
                self.flowers = roses
            } else if flowerCategory.categoryName == "Carnations" {
                self.flowers = carnations
            } else if flowerCategory.categoryName == "Orchids" {
                self.flowers = orchids
            }
            self.selectedFlower = nil
            self.selectedItemIndex = -1
            self.reloadCollectionViews()
        } else {
            let flower = flowers[indexPath.row]
            self.selectedFlower = flower
            selectedItemIndex = indexPath.item
            self.reloadCollectionViews()
        }
    }
}
