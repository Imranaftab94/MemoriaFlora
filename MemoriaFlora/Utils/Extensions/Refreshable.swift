//
//  Refreshable.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation
import UIKit

@objc protocol Refreshable {
    /// The refresh control
    var refreshControl: UIRefreshControl? { get set }
    
    /// The table view
    var tableView: UITableView! { get set }
    
    /// the function to call when the user pulls down to refresh
    @objc func handleRefresh(_ sender: Any)
}


extension Refreshable where Self: UIViewController {
    /// Configure the refresh control for the controller's tableview
    func instantiateRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        self.tableView.refreshControl = refreshControl
    }
    
    func endRefresh() {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    /// Configuring spinner for footer Refresh View
    func createSpinnerFooterView() -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}
