//
//  FlowersVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import UIKit

class FlowersVC: BaseViewController {
    
    @IBOutlet weak var flowersCategoryCollectionView: UICollectionView!
    @IBOutlet weak var flowerItemCollectionView: UICollectionView!
    
    var selectedFlowerCategory: FlowerCategoryModel?
    var selectedFlower: FlowerModel?
    var memory: Memory?

    var onSelectPayment: ((_ selectedCategory: FlowerCategoryModel, _ selectedFlower: FlowerModel) -> ())?
    
    var flowerCategories: [FlowerCategoryModel] = [
        FlowerCategoryModel(flowerType: "Lilies", image: UIImage(named: "Lilies")!),
        FlowerCategoryModel(flowerType: "Roses", image: UIImage(named: "Roses")!),
        FlowerCategoryModel(flowerType: "Carnations", image: UIImage(named: "Carnations")!),
        FlowerCategoryModel(flowerType: "Chrysanthemums", image: UIImage(named: "Chrysanthemums")!),
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

    // Chrysanthemums
    let chrysanthemums: [FlowerModel] = [
        FlowerModel(name: "White Chrysanthemum", price: "$25", image: UIImage(named: "chrysanthemum1")!),
        FlowerModel(name: "Yellow Chrysanthemum", price: "$23", image: UIImage(named: "chrysanthemum2")!),
        FlowerModel(name: "Purple Chrysanthemum", price: "$28", image: UIImage(named: "chrysanthemum3")!),
        FlowerModel(name: "Red Chrysanthemum", price: "$30", image: UIImage(named: "chrysanthemum4")!),
        FlowerModel(name: "Orange Chrysanthemum", price: "$26", image: UIImage(named: "chrysanthemum5")!)
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
    
    var flowers: [FlowerModel] = []
    
    var selectedCategoryIndex = -1
    var selectedItemIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCategoryIndex = 0
        self.selectedFlowerCategory = flowerCategories.first
        self.configureCollectionView()
        self.setNavigationBackButtonColor()
        self.flowers = lilies
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
    
    @IBAction func onClickPurchaseFlowerButton(_ sender: UIButton) {
        guard let category = self.selectedFlowerCategory else {
            self.showAlert(message: "Please select a flower category")
            return
        }
        
        guard let flower = self.selectedFlower else {
            self.showAlert(message: "Please select a flower for condolences")
            return
        }
        
        let vc = SelectPaymentVC.instantiate(selectedCategory: category, selectedFlower: flower, memory: memory!)
        vc.onPayCondolences = { [weak self] in
            guard let self = self else { return }
            guard let selectedCategory = self.selectedFlowerCategory else { return }
            guard let selectedFlower = self.selectedFlower else { return }
            self.onSelectPayment?(selectedCategory, selectedFlower)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension FlowersVC: UICollectionViewDataSource, UICollectionViewDelegate {
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
            cell.categoryNameLabel.text = category.flowerType
            cell.categoryImageView.image = category.image
            
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
            
            cell.flowerNameLabel.text = flower.name
            cell.flowerPriceLabel.text = flower.price
            cell.flowerImageView.image = flower.image
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == flowersCategoryCollectionView {
            let flowerCategory = flowerCategories[indexPath.row]
            self.selectedFlowerCategory = flowerCategory
            
            selectedCategoryIndex = indexPath.item
            if indexPath.row == 0 {
                self.flowers = lilies
            } else if indexPath.row == 1 {
                self.flowers = roses
            } else if indexPath.row == 2 {
                self.flowers = carnations
            } else if indexPath.row == 3 {
                self.flowers = chrysanthemums
            } else if indexPath.row == 4 {
                self.flowers = orchids
            }
            flowersCategoryCollectionView.reloadData()
            flowerItemCollectionView.reloadData()
        } else {
            let flower = flowers[indexPath.row]
            self.selectedFlower = flower
            selectedItemIndex = indexPath.item
            flowerItemCollectionView.reloadData()
        }
    }
}
