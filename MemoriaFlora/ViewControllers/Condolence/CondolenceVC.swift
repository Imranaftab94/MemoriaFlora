//
//  CondolenceVC.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 01/05/2024.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class CondolenceVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var memory: Memory?
    var condolences: [Condolence] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.configureTableView()
//        self.title = "Condolences"
//        self.getCondolences()
    }
    
    class func instantiate(memory: Memory) -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Details)
        vc.memory = memory
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
//    private func getCondolences() {
//        guard let memoryId = self.memory?.memoryKey else { return }
//
//        self.showProgressHUD()
//        
//        let databaseRef = Database.database().reference()
//        
//        databaseRef.child("condolences").child(memoryId).observeSingleEvent(of: .value) { (snapshot) in
//            guard snapshot.exists() else {
//                print("No condolences found for memory ID: \(memoryId)")
//                self.hideProgressHUD()
//                return
//            }
//            
//            var condolences: [Condolence] = []
//            let dispatchGroup = DispatchGroup()
//            
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let condolenceData = childSnapshot.value as? [String: Any] {
//                    var condolence = Condolence.makeCondolence(condolenceData: condolenceData)
//                    
//                    dispatchGroup.enter()
//                    databaseRef.child("users").child(condolence.userId).observeSingleEvent(of: .value) { (userSnapshot) in
//                        defer { dispatchGroup.leave() }
//                        guard let userData = userSnapshot.value as? [String: Any] else { return }
//                        
//                        if let email = userData["email"] as? String,
//                           let name = userData["name"] as? String {
//                            condolence.userName = name
//                            condolence.email = email
//                        }
//                        condolences.append(condolence)
//                    }
//                }
//            }
//            
//            dispatchGroup.notify(queue: .main) {
//                self.hideProgressHUD()
//                condolences.sort { $0.timestamp > $1.timestamp }
//                self.condolences = condolences
//                self.reloadTableView()
//            }
//        }
//    }
}

