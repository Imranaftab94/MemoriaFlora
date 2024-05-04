//
//  EditFlowersVC.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 04/05/2024.
//

import UIKit

class EditFlowersVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flowerCategoryCollectionView: UICollectionView!
    
    var flowers: [FlowerModel] = []
    
    var flowerCategories: [FlowerCategoryModel] = [
        FlowerCategoryModel(flowerType: "Lilies", image: UIImage(named: "Lilies")!),
        FlowerCategoryModel(flowerType: "Roses", image: UIImage(named: "Roses")!),
        FlowerCategoryModel(flowerType: "Carnations", image: UIImage(named: "Carnations")!),
        FlowerCategoryModel(flowerType: "Orchids", image: UIImage(named: "Orchids")!)
    ]
    
    // Lilies
    let lilies: [FlowerModel] = [
        FlowerModel(name: "White Lily", price: "$30", image: UIImage(named: "lilies1")!),
        FlowerModel(name: "Stargazer Lily", price: "$35", image: UIImage(named: "lilies2")!),
        FlowerModel(name: "Casa Blanca Lily", price: "$40", image: UIImage(named: "lilies3")!),
        FlowerModel(name: "Calla Lily", price: "$25", image: UIImage(named: "lilies4")!),
        FlowerModel(name: "Tiger Lily", price: "$28", image: UIImage(named: "lilies5")!)
    ]
    
    // Roses
    let roses: [FlowerModel] = [
        FlowerModel(name: "Red Rose", price: "$20", image: UIImage(named: "rose1")!),
        FlowerModel(name: "White Rose", price: "$18", image: UIImage(named: "rose2")!),
        FlowerModel(name: "Pink Rose", price: "$22", image: UIImage(named: "rose3")!),
        FlowerModel(name: "Yellow Rose", price: "$15", image: UIImage(named: "rose4")!),
        FlowerModel(name: "Black Rose", price: "$25", image: UIImage(named: "rose5")!)
    ]
    
    // Orchids
    let orchids: [FlowerModel] = [
        FlowerModel(name: "Phalaenopsis Orchid", price: "$40", image: UIImage(named: "orchids1")!),
        FlowerModel(name: "Cattleya Orchid", price: "$45", image: UIImage(named: "orchids2")!),
        FlowerModel(name: "Dendrobium Orchid", price: "$38", image: UIImage(named: "orchids3")!),
        FlowerModel(name: "Cymbidium Orchid", price: "$42", image: UIImage(named: "orchids4")!),
        FlowerModel(name: "Vanda Orchid", price: "$50", image: UIImage(named: "orchids5")!)
    ]

    // Carnations
    let carnations: [FlowerModel] = [
        FlowerModel(name: "White Carnation", price: "$15", image: UIImage(named: "carnations1")!),
        FlowerModel(name: "Pink Carnation", price: "$12", image: UIImage(named: "carnations2")!),
        FlowerModel(name: "Red Carnation", price: "$14", image: UIImage(named: "carnations3")!),
        FlowerModel(name: "Yellow Carnation", price: "$10", image: UIImage(named: "carnations4")!),
        FlowerModel(name: "Purple Carnation", price: "$16", image: UIImage(named: "carnations5")!)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = flowers[indexPath.row]

        var actions = [UIContextualAction]()
        
        // Add edit action if the item meets certain conditions
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
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
        
        cell.titleLabel.text = item.name
        cell.dateOfDemiseLabel.text = item.price
                if let url = URL(string: item.image) {
            cell.userImageView.kf.setImage(with: url)
        }
        cell.descriptionLabel.text = item.description
        cell.containerView.layer.cornerRadius = 16
        cell.containerView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 20
        cell.userImageView.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
