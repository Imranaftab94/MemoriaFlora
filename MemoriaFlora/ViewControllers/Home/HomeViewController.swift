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
    @IBOutlet weak var emptyListImageView: UIImageView!
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
        fetchAllMemories(isShowProgress: true)
        instantiateRefreshControl()
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
        // Reference to the memories node for the user
        let memoriesRef = Database.database().reference().child("memories")
        
        // Observe for new changes in memories
        
        memoriesRef.observe(.childAdded) { (snapshot) in
            guard let memoryData = snapshot.value as? [String: Any],
                  let userName = memoryData["userName"] as? String,
                  let description = memoryData["description"] as? String,
                  let imageUrl = memoryData["imageUrl"] as? String,
                  let dateOfDemise = memoryData["demiseDate"] as? String,
                  let timestampString = memoryData["timestamps"] as? TimeInterval else {
                return
            }
            let date = Date(timeIntervalSince1970: timestampString)
            // Create Memory object for the new memory
            let memory = Memory(userName: userName, description: description, imageUrl: imageUrl, dateOfDemise: dateOfDemise, timestamp: date)
            
            // Append the new memory to the array
            self.memories.append(memory)
            
            self.memories.sort { $0.timestamp > $1.timestamp }
            
            self.reloadTableView()
            // Handle the newly added memory, such as updating UI or performing any other action
            print("New memory added:")
            print("User: \(memory.userName), Description: \(memory.description), Image URL: \(memory.imageUrl)")
        }
    }
    
    private func fetchAllMemories(isShowProgress: Bool = false) {
        let memoriesRef = Database.database().reference().child("memories")
        
        if isShowProgress {
            self.showProgressHUD()
        }
        memoriesRef.observeSingleEvent(of: .value) { (snapshot) in
            self.hideProgressHUD()
            self.memories.removeAll() // Clear existing memories
            
            var allMemories: [Memory] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let memoryData = snapshot.value as? [String: Any],
                   let userName = memoryData["userName"] as? String,
                   let description = memoryData["description"] as? String,
                   let imageUrl = memoryData["imageUrl"] as? String,
                   let dateOfDemise = memoryData["demiseDate"] as? String,
                   let timestampString = memoryData["timestamps"] as? TimeInterval
                {
                    let date = Date(timeIntervalSince1970: timestampString)
                    let memory = Memory(userName: userName, description: description, imageUrl: imageUrl, dateOfDemise: dateOfDemise, timestamp: date)
                    allMemories.append(memory)
                }
            }
            
            allMemories.sort { $0.timestamp > $1.timestamp }
            self.memories = allMemories
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
            if self.memories.count <= 0 {
                self.emptyListImageView.isHidden = false
            } else {
                self.emptyListImageView.isHidden = true
            }
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
        cell.dateOfDemiseLabel.text = "Date of Demise: \(item.dateOfDemise)"
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
        let vc = DetailViewController.instantiate(fromAppStoryboard: .Details)
        vc.memory = memories[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
