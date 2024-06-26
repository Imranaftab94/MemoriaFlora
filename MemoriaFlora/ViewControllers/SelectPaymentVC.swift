//
//  SelectPaymentVC.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import UIKit

class SelectPaymentVC: BaseViewController {
    @IBOutlet weak var containerView1: UIView!
    @IBOutlet weak var containerView3: UIView!
    @IBOutlet weak var containerView2: UIView!
    
    @IBOutlet weak var payButton: UIButton!
    
    let activeBorderColor: UIColor = UIColor.init(hexString: "#793EE5")
    let inactiveBorderColor: UIColor = UIColor.init(hexString: "#0B0B0B")
    
    var selectedFlowerCategory: FlowerCategoryModel?
    var selectedFlower: FlowerModel?
    var memory: Memory?

    var onPayCondolences: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped(_:)))
        containerView1.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped(_:)))
        containerView2.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped(_:)))
        containerView3.addGestureRecognizer(tapGestureRecognizer3)
        
        // Set initial border colors
        setBorderColor(for: containerView1, active: false)
        setBorderColor(for: containerView2, active: false)
        setBorderColor(for: containerView3, active: false)
        
        containerView2.layer.cornerRadius = 16.0
        containerView2.layer.masksToBounds = true
        
        containerView3.layer.cornerRadius = 16.0
        containerView3.layer.masksToBounds = true
        
        containerView1.layer.cornerRadius = 16.0
        containerView1.layer.masksToBounds = true
        payButton.setTitle("Pay".localized(), for: .normal)
    }
    
    //MARK: - Send Email
    
    class func instantiate(selectedCategory: FlowerCategoryModel, selectedFlower: FlowerModel, memory: Memory) -> Self {
        let vc = self.instantiate(fromAppStoryboard: .Flowers)
        vc.selectedFlower = selectedFlower
        vc.selectedFlowerCategory = selectedCategory
        vc.memory = memory
        return vc
    }
    
    @IBAction func onClickPayButton(_ sender: UIButton) {
        self.onPayCondolences?()
        self.showAlert(message: "Payment Made Successfully".localized(), title: "Success".localized(), action: UIAlertAction(title: "OK".localized(), style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
    }
    
    
    @objc func containerViewTapped(_ sender: UITapGestureRecognizer) {
        // Determine which container view was tapped
        if let tappedView = sender.view {
            // Reset border colors for all container views
            setBorderColor(for: containerView1, active: false)
            setBorderColor(for: containerView2, active: false)
            setBorderColor(for: containerView3, active: false)
            
            // Set active border color for the tapped container view
            setBorderColor(for: tappedView, active: true)
        }
    }
    
    func setBorderColor(for view: UIView, active: Bool) {
        if active {
            view.layer.borderColor = activeBorderColor.cgColor
            view.layer.borderWidth = 2.0
        } else {
            view.layer.borderColor = inactiveBorderColor.cgColor
            view.layer.borderWidth = 0.0
        }
    }
}
