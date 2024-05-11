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
    let createdByName: String?
    var funeralAgency: String?
    
    init(uid: String, userName: String, description: String, imageUrl: String, dateOfDemise: String, timestamp: Date, condolences: Int, memoryKey: String?, createdByEmail: String, createdById: String, createdByName: String, funeralAgency: String?) {
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
        self.createdByName = createdByName
        self.funeralAgency = funeralAgency
    }
    
    static func createMemory(from memoryData: [String: Any]) -> Memory? {
        guard let uid = memoryData["id"] as? String,
              let userName = memoryData["userName"] as? String,
              let description = memoryData["description"] as? String,
              let imageUrl = memoryData["imageUrl"] as? String,
              let dateOfDemise = memoryData["demiseDate"] as? String,
              let condolences = memoryData["condolences"] as? Int,
              let timestampString = memoryData["timestamps"] as? TimeInterval,
              let memoryKey = memoryData["memoryId"] as? String,
              let createdByEmail = memoryData["createdByEmail"] as? String,
              let createdById = memoryData["createdById"] as? String,
              let createdByName = memoryData["createdByName"] as? String else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timestampString)
        let funeralAgency = memoryData["funeralAgency"] as? String ?? ""
        return Memory(uid: uid,
                      userName: userName,
                      description: description,
                      imageUrl: imageUrl,
                      dateOfDemise: dateOfDemise,
                      timestamp: date,
                      condolences: condolences,
                      memoryKey: memoryKey,
                      createdByEmail: createdByEmail,
                      createdById: createdById, 
                      createdByName: createdByName,
                      funeralAgency: funeralAgency)
    }
}
