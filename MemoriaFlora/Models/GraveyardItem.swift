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
    
    init(userName: String, description: String, imageUrl: String) {
        self.userName = userName
        self.description = description
        self.imageUrl = imageUrl
    }
}
