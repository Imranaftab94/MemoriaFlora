//
//  FlowerModel.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 20/04/2024.
//

import Foundation
import UIKit

struct FlowerCategoryModel {
    var categoryName: String?
    var categoryId: String?
    var imageUrl: String?
    
    static func createCategory(data: [String: Any]) {
        
    }
}

struct FlowerModel {
    var category: String?
    var flowerName: String?
    var flowerPrice: String?
    var flowerId: String?
    var imageUrl: String?
    var timestamp: TimeInterval?
    var categoryId: String?
    var identifier: String?
}
