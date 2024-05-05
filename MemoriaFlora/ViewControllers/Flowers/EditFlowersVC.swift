//
//  EditFlowersVC.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 04/05/2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class EditFlowersVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flowerCategoryCollectionView: UICollectionView!
    
    var flowers: [FlowerModel] = []
    
    var selectedFlowerCategory: FlowerCategoryModel?
    var selectedFlower: FlowerModel?
    
    var selectedCategoryIndex = -1
    var selectedItemIndex = -1
    
    var flowerCategories: [FlowerCategoryModel] = []
    
    var lilies: [FlowerModel] = []
    var roses: [FlowerModel] = []
    var orchids: [FlowerModel] = []
    var carnations: [FlowerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureCollectionView()
        self.fetchFlowerCategories()
        self.fetchFlowers()
        self.setNavigationBackButtonColor()
        
        self.title = "Edit Flowers"
    }
    
    class func instantiate() -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Flowers)
        return vc
    }
    
    private func setNavigationBackButtonColor() {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#865EE2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#865EE2")]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func fetchFlowerCategories() {
        let ref = Database.database().reference().child("flowerscategory")
        
        // Create a dispatch group
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
            self.flowerCategoryCollectionView.reloadData()
        } withCancel: { (error) in
            self.showAlert(message: error.localizedDescription)
        }
    }

    private func fetchFlowers() {
        self.showProgressHUD()
        let ref = Database.database().reference().child("flowers")
        
        // Create a dispatch group
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
                          let categoryId = flowerIdData["categoryId"] as? String else {
                        continue
                    }
                    let flower = FlowerModel(category: category, flowerName: flowerName, flowerPrice: flowerPrice, flowerId: flowerId, imageUrl: imageUrl, timestamp: timestamp, categoryId: categoryId)
                    
                    flowers.append(flower)
                }
            }
            
            self.roses = flowers.filter { $0.category == "Roses" }
            self.orchids = flowers.filter { $0.category == "Orchids" }
            self.carnations = flowers.filter { $0.category == "Carnations" }
            self.lilies = flowers.filter { $0.category == "Lilies" }
            self.flowers = flowers
            self.reloadTableView()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.hideProgressHUD()
        }
    }
}

extension EditFlowersVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func configureCollectionView() {
        flowerCategoryCollectionView.dataSource = self
        flowerCategoryCollectionView.delegate = self
        
        flowerCategoryCollectionView.register(UINib(nibName: "FlowersCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FlowersCategoryCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flowerCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        if let imageUrl = category.imageUrl {
            if let url = URL(string: imageUrl) {
                cell.categoryImageView.kf.setImage(with: url)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        flowerCategoryCollectionView.reloadData()
        self.reloadTableView()
    }
}



extension EditFlowersVC: UITableViewDataSource, UITableViewDelegate {
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GraveyardTableViewCell", bundle: nil), forCellReuseIdentifier: "GraveyardTableViewCell")
        tableView.separatorStyle = .none
        self.reloadTableView()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = flowers[indexPath.row]

        var actions = [UIContextualAction]()
        
        // Add edit action if the item meets certain conditions
        let editAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.navigationController?.pushViewController(UpdateFlowerVC.instantiate(flowerToUpdate: item), animated: true)
            completionHandler(true)
        }
        if let editIcon = UIImage(named: "ic_edit_post") {
            editAction.image = editIcon
        }
            
        editAction.backgroundColor = UIColor(hexString: "F7F7F7")
        actions.append(editAction)
        

        let swipeConfiguration = UISwipeActionsConfiguration(actions: actions)
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let isAdmin = AppController.shared.user?.admin else { return false }
        if isAdmin {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flowers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraveyardTableViewCell", for: indexPath) as! GraveyardTableViewCell
        
        let item = flowers[indexPath.row]
        
        cell.titleLabel.text = item.flowerName
        cell.dateOfDemiseLabel.text = "$\(item.flowerPrice ?? "")"
        cell.descriptionLabel.text = item.category ?? ""
        if let url = URL(string: item.imageUrl ?? "") {
            cell.userImageView.kf.setImage(with: url)
        }
        cell.containerView.layer.cornerRadius = 16
        cell.containerView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 20
        cell.userImageView.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
