//
//  AppController.swift
//  Caro Estinto
//
//  Created by NabeelSohail on 26/04/2024.
//

import Foundation

class AppController {
    
    static let shared = AppController()
    
    private init() {}

    
    private var _user: User?
    var user: User? {
        get {
            if _user == nil {
                self._user = MyUserDefaults.getUser()
            }
            return _user
        }
        set(user) {
            _user = user
            MyUserDefaults.setUser(user)
        }
    }
}
