//
//  Functions.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import Foundation
import UIKit

func animateTransition(to viewController: UIViewController, view: UIView) {
    UIView.transition(with: view,
                      duration: 0.8,
                      options: .transitionFlipFromRight,
                      animations: {
        UIApplication.shared.windows.first?.rootViewController = viewController
    },
                      completion: nil)
}
