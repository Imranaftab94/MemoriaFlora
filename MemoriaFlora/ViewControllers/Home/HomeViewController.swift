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
            guard let memoryData = snapshot.value as? [String: Any] else {
                return
            }
            
            if let memory = Memory.createMemory(from: memoryData) {
                self.memories.append(memory)
            }
            
            self.memories.sort { $0.timestamp > $1.timestamp }
            
            self.reloadTableView()
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
                   let memoryData = snapshot.value as? [String: Any] {
                    if let memory = Memory.createMemory(from: memoryData) {
                        allMemories.append(memory)
                    }
                }
            }
            
            allMemories.sort { $0.timestamp > $1.timestamp }
            self.memories = allMemories
            self.reloadTableView()
        }
    }
    
    private func deleteMemory(withUID uid: String, completion: (() -> Void)? = nil) {
        let memoriesRef = Database.database().reference().child("memories")
        let memoryRef = memoriesRef.child(uid)
        memoryRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting memory with UID \(uid): \(error.localizedDescription)")
            } else {
                print("Memory with UID \(uid) deleted successfully!")
            }
            completion?()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = memories[indexPath.row]

        var actions = [UIContextualAction]()

        // Add delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this memory?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            alert.addAction(cancelAction)
            
            let deleteConfirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.showProgressHUD()
                self.deleteMemory(withUID: item.uid) {
                    self.hideProgressHUD()
                    self.memories.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                    completionHandler(true)
                }
            }
            alert.addAction(deleteConfirmAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = .red // Customize delete button color if needed
        actions.append(deleteAction)
        
        // Add edit action if the item meets certain conditions
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            // Handle edit action here
            // For example, you can show an edit screen for the selected item
            print("Edit button tapped for item at index \(indexPath.row)")
            completionHandler(true)
        }
        editAction.backgroundColor = .blue // Customize edit button color if needed
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
