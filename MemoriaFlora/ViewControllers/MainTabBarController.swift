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
        
        self.configureTabBar()
        self.tabBar.inActiveTintColor()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = UIColor(hexString: "#793EE5")
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            tabBar.barTintColor = UIColor.appPurpleColor
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 12)
    }
    
    private func configureTabBar() {
        let homeVC = UINavigationController.init(rootViewController: HomeViewController.instantiate(fromAppStoryboard: .Main))
        homeVC.tabBarItem = UITabBarItem(title: "Menu", image: #imageLiteral(resourceName: "ic_home"), tag: 0)
        
        let createPost = UINavigationController.init(rootViewController: CreatePostVC.instantiate(fromAppStoryboard: .Main))
        createPost.tabBarItem = UITabBarItem(title: "Add", image: #imageLiteral(resourceName: "ic_add"), tag: 1)
        
        let funeralAgency = UINavigationController.init(rootViewController: HomeViewController.instantiate(fromAppStoryboard: .Main))
        funeralAgency.tabBarItem = UITabBarItem(title: "Funeral Agency", image: #imageLiteral(resourceName: "agency"), tag: 2)
        
        let search = UINavigationController.init(rootViewController: HomeViewController.instantiate(fromAppStoryboard: .Main))
        search.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search_tab"), tag: 3)
        
        var tabBarList: [UINavigationController] = []
        
        tabBarList.append(homeVC)
        tabBarList.append(createPost)
        tabBarList.append(funeralAgency)
        tabBarList.append(search)
                
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
            self.navigationController?.pushViewController(HomeViewController.instantiate(fromAppStoryboard: .Main), animated: true)
        } else if viewController == tabBarController.viewControllers?[1] {
            self.navigationController?.pushViewController(CreatePostVC.instantiate(fromAppStoryboard: .Main), animated: true)
            return true
        } else if viewController == tabBarController.viewControllers?[2] {
            // MOVE TO HYPERLINK HERE ON FUNERAL AGENCY
            if let url = URL(string: "http://caroestinto.com/agenziefunebri") {
                UIApplication.shared.open(url)
            }
            return false
        } else if viewController == tabBarController.viewControllers?[3] {
            // OPEN SEARCH HERE
//            self.navigationController?.pushViewController(HomeViewController.instantiate(), animated: true)
            if let funeralAgencyVC = viewController as? UINavigationController,
               let funeralAgencyRootVC = funeralAgencyVC.viewControllers.first as? HomeViewController {
                funeralAgencyRootVC.activateTextField() // Implement this method in YourFuneralAgencyViewController
            }

            return true
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
                item.image =  item.image?.withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
            }
        }
    }
}
