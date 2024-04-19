//
//  HomeViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit

class HomeViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var graveyardData: [GraveyardItem] = [
        GraveyardItem(title: "John Doe", itemDescription: "Beloved husband and father"),
        GraveyardItem(title: "Jane Smith", itemDescription: "Loving mother and friend"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        userProfileImageView.layer.cornerRadius = 16
        userProfileImageView.layer.masksToBounds = true
    }
    
    @IBAction func onClickCreatePostButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
            let createPostVC = storyboard.instantiateViewController(withIdentifier: "CreatePostVC") as! CreatePostVC
            self.navigationController?.pushViewController(createPostVC, animated: true)
        }
    }
}


extension HomeViewController: UITableViewDataSource {
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GraveyardTableViewCell", bundle: nil), forCellReuseIdentifier: "GraveyardTableViewCell")
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graveyardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraveyardTableViewCell", for: indexPath) as! GraveyardTableViewCell
        
        let item = graveyardData[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.itemDescription
        cell.containerView.layer.cornerRadius = 16
        cell.containerView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 16
        cell.userImageView.layer.masksToBounds = true
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
