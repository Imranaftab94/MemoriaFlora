//
//  LocalizationFile.swift
//  Caro Estinto
//
//  Created by ImranAftab on 6/2/24.
//

import Foundation
import Spring

enum SupportedLanguage: String {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case italian = "it"
    case portuguese = "pt"
}

func getCurrentLanguage() -> SupportedLanguage? {
    if let currentLanguageCode = Locale.preferredLanguages.first {
        let primaryLanguageCode = currentLanguageCode.components(separatedBy: "-").first ?? ""
        if let language = SupportedLanguage(rawValue: primaryLanguageCode) {
            return language
        }
    }
    return nil
}

class Label_Localize: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyTheme()
    }
    
    func applyTheme() {
        self.text = self.text?.localized()
    }
}

class Button_Localize: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyTheme()
    }
    
    func applyTheme() {
        self.setTitle(self.titleLabel!.text?.localized(), for: UIControl.State.normal)
    }
}

extension String {
    func localized() -> String {
        if let appLanguage = DefaultManager.getAppLanguage() {
            if appLanguage == SupportedLanguage.spanish.rawValue {
                let path = Bundle.main.path(forResource: "es", ofType: "lproj")
                let bundle = Bundle(path: path!)
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
            } else if appLanguage == SupportedLanguage.italian.rawValue {
                let path = Bundle.main.path(forResource: "it", ofType: "lproj")
                let bundle = Bundle(path: path!)
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
            } else if appLanguage == SupportedLanguage.portuguese.rawValue {
                let path = Bundle.main.path(forResource: "pt-PT", ofType: "lproj")
                let bundle = Bundle(path: path!)
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
            } else if appLanguage == SupportedLanguage.french.rawValue {
                let path = Bundle.main.path(forResource: "fr", ofType: "lproj")
                let bundle = Bundle(path: path!)
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
            } else {
                let path = Bundle.main.path(forResource: "en", ofType: "lproj")
                let bundle = Bundle(path: path!)
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
            }
        }
        let path = Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
    }
}

class DefaultManager: NSObject {
    static let KEY_AppLanguage = "appLanguage"
    
    static func setAppLanguage(ver: String) {
        UserDefaults.standard.set(ver, forKey: KEY_AppLanguage)
        UserDefaults.standard.synchronize()
    }
    
    static func getAppLanguage() -> String? {
        if let ver = UserDefaults.standard.value(forKey: KEY_AppLanguage) as? String {
            return ver
        }
        return nil
    }
    
    static func removeAppLanguage() {
        UserDefaults.standard.removeObject(forKey: KEY_AppLanguage)
        UserDefaults.standard.synchronize()
    }
}
