//
//  GraveyardItem.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation

struct Memory {
    let userName: String
    let description: String
    let imageUrl: String
    let dateOfDemise: String
    
    init(userName: String, description: String, imageUrl: String, dateOfDemise: String) {
        self.userName = userName
        self.description = description
        self.imageUrl = imageUrl
        self.dateOfDemise = dateOfDemise
    }
}
