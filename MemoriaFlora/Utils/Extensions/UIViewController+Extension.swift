//
//  UIViewController+Extension.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import Foundation
import UIKit

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    
    func present(newRootViewController: UIViewController) {
        DispatchQueue.main.async {
            UIView.transition(from: self.view, to: newRootViewController.view, duration: 0.6, options: [.transitionFlipFromTop], completion: { completed in
                UIApplication.shared.keyWindow?.rootViewController = newRootViewController
            })
        }
    }
    
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
}
