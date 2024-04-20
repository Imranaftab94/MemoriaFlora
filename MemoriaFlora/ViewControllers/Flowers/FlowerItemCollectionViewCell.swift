//
//  FlowerItemCollectionViewCell.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import UIKit

class FlowerItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var flowerNameLabel: UILabel!
    @IBOutlet weak var flowerPriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
