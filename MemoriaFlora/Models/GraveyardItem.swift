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
    let condolences: Int
    let memoryKey: String?
    let createdByEmail: String?
    let createdById: String?
    
    init(uid: String, userName: String, description: String, imageUrl: String, dateOfDemise: String, timestamp: Date, condolences: Int, memoryKey: String?, createdByEmail: String, createdById: String) {
        self.uid = uid
        self.userName = userName
        self.description = description
        self.imageUrl = imageUrl
        self.dateOfDemise = dateOfDemise
        self.timestamp = timestamp
        self.condolences = condolences
        self.memoryKey = memoryKey
        self.createdById = createdById
        self.createdByEmail = createdByEmail
    }
}
