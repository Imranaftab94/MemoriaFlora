//
//  CondolenceModel.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 01/05/2024.
//

import Foundation


struct Condolence: Codable {
    let userId: String
    let timestamp: TimeInterval
    let flowerPrice: String
    let flowerType: String
    let flowerName: String
    let flowerImageUrl: String
    var userName: String?
    var email: String?
    
    init(userId: String, timestamp: TimeInterval, flowerPrice: String, flowerType: String, flowerName: String, flowerImageUrl: String, userName: String?, email: String?) {
        self.userId = userId
        self.timestamp = timestamp
        self.flowerPrice = flowerPrice
        self.flowerType = flowerType
        self.flowerName = flowerName
        self.flowerImageUrl = flowerImageUrl
        self.userName = userName
        self.email = email
    }
    
    static func makeCondolence(condolenceData: [String: Any]) -> Condolence {
        let userId = condolenceData["userId"] as? String ?? ""
        let timestamp = condolenceData["timestamp"] as? TimeInterval ?? 0.0
        let flowerPrice = condolenceData["flowerPrice"] as? String ?? ""
        let flowerType = condolenceData["flowerType"] as? String ?? ""
        let flowerName = condolenceData["flowerName"] as? String ?? ""
        let flowerImageUrl = condolenceData["flowerImageUrl"] as? String ?? ""
        
        let condolence = Condolence(userId: userId,
                                    timestamp: timestamp,
                                    flowerPrice: flowerPrice,
                                    flowerType: flowerType,
                                    flowerName: flowerName,
                                    flowerImageUrl: flowerImageUrl, 
                                    userName: "",
                                    email: "")
        return condolence
    }
}
