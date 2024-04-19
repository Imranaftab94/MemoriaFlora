//
//  HomeViewController.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class HomeViewController: BaseViewController, Refreshable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var refreshControl: UIRefreshControl?
        
    var memories: [Memory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        userProfileImageView.layer.cornerRadius = 16
        userProfileImageView.layer.masksToBounds = true
        observeMemories()
        
        self.instantiateRefreshControl()
    }
    
    @IBAction func onClickProfileButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @IBAction func onClickCreatePostButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createPostVC = storyboard.instantiateViewController(withIdentifier: "CreatePostVC") as! CreatePostVC
            self.navigationController?.pushViewController(createPostVC, animated: true)
        }
    }
    
    private func observeMemories() {
        // Assuming userID is the ID of the user whose memories you want to fetch
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not logged in")
            return
        }
        
        // Reference to the memories node for the user
        let memoriesRef = Database.database().reference().child("users").child(userID).child("memories")
        
        // Observe for new changes in memories
        
        self.showProgressHUD()
        memoriesRef.observe(.childAdded) { (snapshot) in
            self.hideProgressHUD()
            guard let memoryData = snapshot.value as? [String: Any],
                  let userName = memoryData["userName"] as? String,
                  let description = memoryData["description"] as? String,
                  let imageUrl = memoryData["imageUrl"] as? String else {
                return
            }
            
            // Create Memory object for the new memory
            let memory = Memory(userName: userName, description: description, imageUrl: imageUrl)
            
            // Append the new memory to the array
            self.memories.append(memory)
            
            self.reloadTableView()
            // Handle the newly added memory, such as updating UI or performing any other action
            print("New memory added:")
            print("User: \(memory.userName), Description: \(memory.description), Image URL: \(memory.imageUrl)")
        }
    }
    
    private func fetchAllMemories() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not logged in")
            return
        }
        
        let memoriesRef = Database.database().reference().child("users").child(userID).child("memories")
        
        memoriesRef.observeSingleEvent(of: .value) { (snapshot) in
            self.memories.removeAll() // Clear existing memories
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let memoryData = snapshot.value as? [String: Any],
                   let userName = memoryData["userName"] as? String,
                   let description = memoryData["description"] as? String,
                   let imageUrl = memoryData["imageUrl"] as? String {
                    let memory = Memory(userName: userName, description: description, imageUrl: imageUrl)
                    self.memories.append(memory)
                }
            }
            
            self.reloadTableView()
        }
    }
    
    func handleRefresh(_ sender: Any) {
        self.fetchAllMemories()
    }
}


extension HomeViewController: UITableViewDataSource {
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GraveyardTableViewCell", bundle: nil), forCellReuseIdentifier: "GraveyardTableViewCell")
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraveyardTableViewCell", for: indexPath) as! GraveyardTableViewCell
        
        let item = memories[indexPath.row]
        
        cell.titleLabel.text = item.userName
        if let url = URL(string: item.imageUrl) {
            cell.userImageView.kf.setImage(with: url)
        }
        cell.descriptionLabel.text = item.description
        cell.containerView.layer.cornerRadius = 16
        cell.containerView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 20
        cell.userImageView.layer.masksToBounds = true
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
