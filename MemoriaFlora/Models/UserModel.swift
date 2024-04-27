//
//  UserModel.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation


struct User: Codable {
    var name: String?
    var email: String?
    var userDescription: String?
    var admin: Bool?
    var userId: String?
}
