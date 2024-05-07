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
import UserNotifications
import FirebaseDynamicLinks

class HomeViewController: BaseViewController, Refreshable, UIGestureRecognizerDelegate {
    @IBOutlet weak var editFlowerButton: UIView!
    @IBOutlet weak var editFlowerImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    var refreshControl: UIRefreshControl?
        
    var memories: [Memory] = []
    var allMemoryUsers: [Memory] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureTableView()
        userProfileImageView.layer.cornerRadius = 16
        userProfileImageView.layer.masksToBounds = true
        observeMemories()
        fetchAllMemories(isShowProgress: true)
        instantiateRefreshControl()
        configureSearchView()
        updateUserFcmToken()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        searchTextField.delegate = self
        
        if AppController.shared.user?.admin ?? false {
            self.showAlert(message: "This is an admin account, You can swipe left to delete or edit memories, You can also edit flower names images and prices")
            self.editFlowerButton.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(activeSearch), name: Notification.Name("ActiveSearchNotification"), object: nil)
    }
    
    @objc func activeSearch() {
        searchTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let link = MyUserDefaults.getDynamicLink() {
            MyUserDefaults.setDynamicLink(nil)
            self.handleDynamicLink(link)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: tableView) {
            return false
        }
        return true
    }
    
    @objc func handleTap() {
        searchTextField.resignFirstResponder()
    }
    
    private func updateUserFcmToken() {
        let updatedData: [String: Any] = [
            "fcmToken": AppController.shared.fcmToken
        ]
        
        guard let uid = AppController.shared.user?.userId else { return }
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(uid).updateChildValues(updatedData) { (error, ref) in
            if let error = error {
                print("An error occurred while updating FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token updated successfully!")
            }
        }
    }
    
    private func configureSearchView() {
        self.searchTextField.delegate = self
        self.searchView.layer.cornerRadius = 16
        self.searchView.layer.masksToBounds = true
        
        searchView.layer.borderColor = .none
        searchView.layer.borderWidth = 0.4
    }

    @IBAction func onClickProfileButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(profileVC, animated: true)            
        }
    }
    
    @IBAction func onClickEditFlowersButton(_ sender: UIButton) {
        self.navigationController?.pushViewController(EditFlowersVC.instantiate(), animated: true)
    }
    
    @IBAction func agencyButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "http://caroestinto.com/agenziefunebri") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onClickCreatePostButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("CreatePostNotification"), object: nil)
    }
    
    private func observeMemories() {
        let memoriesRef = Database.database().reference().child("memories")
                
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
        
        memoriesRef.observe(.childChanged) { (snapshot) in
            guard let memoryData = snapshot.value as? [String: Any] else {
                return
            }
            
            if let index = self.memories.firstIndex(where: { $0.memoryKey == snapshot.key }) {
                if let updatedMemory = Memory.createMemory(from: memoryData) {
                    self.memories[index] = updatedMemory
                    self.reloadTableView()
                }
            }
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
            self.allMemoryUsers = allMemories
            self.checkAndDeleteOldMemories()
            self.reloadTableView()
        }
    }
    
    private func checkAndDeleteOldMemories() {
        
        if AppController.shared.user?.admin == true {
            
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!

            for memory in allMemoryUsers {
                if memory.timestamp < sixMonthsAgo {
                    print("The memory is older than six months.")
                    guard let memoryKey = memory.memoryKey else { return }
                    self.deleteMemory(withUID: memoryKey)
                } else {
                    print("The memory is not older than six months.")
                }
            }
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
    
    private func handleDynamicLink(_ url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("Dynamic link URL: \(url)")
            if let url = URL(string: url),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                                
                guard let id = queryItems.first(where: { $0.name == "id" })?.value else {
                    return
                }
                
                // Extracting memoryKey
                guard let memoryKey = queryItems.first(where: { $0.name == "memoryKey" })?.value else {
                    return
                }
                
                let memory = Memory(uid: id, userName: "", description: "", imageUrl: "", dateOfDemise: "", timestamp: Date(), condolences: 0, memoryKey: memoryKey, createdByEmail: "", createdById: "", createdByName: "")
                let vc = DetailViewController.instantiate(fromAppStoryboard: .Details)
                vc.memory = memory
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this memory?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            alert.addAction(cancelAction)
            
            let deleteConfirmAction = UIAlertAction(title: "Delete Post", style: .destructive) { _ in
                guard let key = item.memoryKey else { return }
                self.showProgressHUD()
                self.deleteMemory(withUID: key) {
                    self.hideProgressHUD()
                    tableView.beginUpdates()
                    self.memories.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.reloadTableView()
                    }
                    completionHandler(true)
                }
            }
            alert.addAction(deleteConfirmAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        if let editIcon = UIImage(named: "ic_delete_trash") {
            deleteAction.image = editIcon
        }
            
        deleteAction.backgroundColor = UIColor(hexString: "F7F7F7")
        actions.append(deleteAction)
        
        // Add edit action if the item meets certain conditions
        let editAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let vc = CreatePostVC.instantiate(fromAppStoryboard: .Main)
            vc.memory = item
            vc.isEditingEnabled = true
            self.navigationController?.pushViewController(vc, animated: true)
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


extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField {
            // Change border color of username container
            searchView.layer.borderColor = activeBorderColor.cgColor
            searchView.layer.borderWidth = 2.0
        } else {
            searchView.layer.borderColor = .none
            searchView.layer.borderWidth = 0.4
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTextField {
            searchView.layer.borderColor = .none
            searchView.layer.borderWidth = 0.4
        }
    }
    
    // UITextFieldDelegate method to filter users when text changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return true
        }
        if searchText.isEmpty {
            memories = allMemoryUsers
        } else {
            memories = allMemoryUsers.filter { $0.userName.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
        return true
    }
}
