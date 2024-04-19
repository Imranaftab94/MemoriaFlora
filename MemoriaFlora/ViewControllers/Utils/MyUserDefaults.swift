//
//  MyUserDefaults.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation

class MyUserDefaults: NSObject {
    static func getUser() -> User? {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: UserDefaults.keys.user) {
            return try? decoder.decode(User.self, from: data)
        }
        return nil
    }
    
    static func setUser(_ userData: User?) {
        if let userData = userData {
            let encoder = JSONEncoder()
            do {
                let encodedData = try encoder.encode(userData)
                UserDefaults.standard.set(encodedData, forKey: UserDefaults.keys.user)
            } catch {
                print("error: ", error)
            }
        }
        UserDefaults.standard.synchronize()
    }
}


extension UserDefaults {
    enum keys {
        static let user = "user"
    }
}
