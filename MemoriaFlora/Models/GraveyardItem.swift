//
//  GraveyardItem.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation

struct Memory {
    let uid: String
    let userName: String
    let description: String
    let imageUrl: String
    let dateOfDemise: String
    let timestamp: Date
    
    init(uid: String, userName: String, description: String, imageUrl: String, dateOfDemise: String, timestamp: Date) {
        self.uid = uid
        self.userName = userName
        self.description = description
        self.imageUrl = imageUrl
        self.dateOfDemise = dateOfDemise
        self.timestamp = timestamp
    }
}
