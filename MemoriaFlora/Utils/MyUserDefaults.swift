//
//  MyUserDefaults.swift
//  MemoriaFlora
//
//  Created by NabeelSohail on 19/04/2024.
//

import Foundation
import FirebaseDynamicLinks

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
    
    static func getRememberMe() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.keys.rememberMe)
    }
    
    static func setRememberMe(_ rememberMe: Bool) {
        UserDefaults.standard.set(rememberMe, forKey: UserDefaults.keys.rememberMe)
        UserDefaults.standard.synchronize()
    }
    
    static func removeRememberMe() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.keys.rememberMe)
        UserDefaults.standard.synchronize()
    }
    
    static func removeUser() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.keys.user)
        UserDefaults.standard.removeObject(forKey: UserDefaults.keys.rememberMe)
        UserDefaults.standard.synchronize()
    }
    
    static func setDynamicLink(_ link: String?) {
        if let link = link {
            UserDefaults.standard.setValue(link, forKey: UserDefaults.keys.dynamicLink)
        } else {
            UserDefaults.standard.setValue(nil, forKey: UserDefaults.keys.dynamicLink)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func getDynamicLink() -> String? {
        if let savedLink = UserDefaults.standard.value(forKey: UserDefaults.keys.dynamicLink) as? String {
            return savedLink
        } else {
            return nil
        }
    }
}


extension UserDefaults {
    enum keys {
        static let user = "user"
        static let rememberMe = "rememberMe"
        static let dynamicLink = "dynamicLink"
    }
}
