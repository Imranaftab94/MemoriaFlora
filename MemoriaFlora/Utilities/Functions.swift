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

func createCondolencesEmail(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Dear \(recipientName),

    We wanted to share with you a heartwarming gesture made by \(purchaserName). They have just purchased a beautiful bouquet of \(flowerName) from our app, intending to honor and remember your loved departed person.

    It is a touching expression of sympathy and support during this difficult time. We hope that this small gesture brings some comfort to you and your family.

    Please know that our thoughts are with you, and we are here for you if you need anything.

    With heartfelt condolences,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}
