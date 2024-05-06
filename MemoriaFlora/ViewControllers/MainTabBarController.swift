//
//  MainTabBarController.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 29/04/2024.
//

import Foundation
import UIKit

class MainTabbarController: UITabBarController {
    
    private var middleButton = UIButton()
    var viewControllerTabBarItems: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.configureTabBar()
        
        self.setupMiddleButton()
        
        self.tabBar.inActiveTintColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .systemBackground
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appPurpleColor]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.appPurpleColor], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            tabBar.barTintColor = UIColor.white
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 12)
    }
    
    private func configureTabBar() {
        let dashboardVC = UINavigationController.init(rootViewController: HomeViewController.instantiate(fromAppStoryboard: .Main))
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: #imageLiteral(resourceName: "ic_dashboard"), tag: 0)
        
//                let filesVC = UINavigationController.init(rootViewController: FilesVC.instantiate(fromAppStoryboard: .Main))
//                filesVC.tabBarItem = UITabBarItem(title: "Files", image: #imageLiteral(resourceName: "icn_files"), tag: 1)
//        
//                let filesVC = UINavigationController.init(rootViewController: FilesVC.instantiate(fromAppStoryboard: .Main))
        //                filesVC.tabBarItem = UITabBarItem(title: "Files", image: #imageLiteral(resourceName: "icn_files"), tag: 2)
        
        
        var tabBarList: [UINavigationController] = []
        
        tabBarList.append(dashboardVC)
        
        viewControllers = tabBarList
        
        viewControllerTabBarItems = tabBarList
        
        self.tabBar.barTintColor = UIColor.white
        
        self.delegate = self
    }
    
    private func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 70, height: 70)
        middleButton.backgroundColor = UIColor.appPurpleColor
        middleButton.layer.cornerRadius = 20
        middleButton.layer.masksToBounds = true
        middleButton.clipsToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(onTappMiddleButton), for: .touchUpInside)
        middleButton.setImage(#imageLiteral(resourceName: "ic_upload_file"), for: .normal)
        self.tabBar.addSubview(middleButton)
    }
    
    @objc func onTappMiddleButton() {
        
    }
}

extension MainTabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[0] {
            
        } else if viewController == tabBarController.viewControllers?[1] {
            
        } else if viewController == tabBarController.viewControllers?[3] {
            
        } else if viewController == tabBarController.viewControllers?[4] {
            
            
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }
}

extension UITabBar {
    func inActiveTintColor() {
        if let items = items{
            for item in items{
                if item != items[2] {
                    item.image =  item.image?.withRenderingMode(.alwaysOriginal)
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red: 166/255, green: 171/255, blue: 189/255, alpha: 1.0)], for: .normal)
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red: 72/255, green: 128/255, blue: 215/255, alpha: 1.0)], for: .selected)
                }
            }
        }
    }
}
