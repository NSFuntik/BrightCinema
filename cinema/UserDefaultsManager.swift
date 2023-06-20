//
//  UserDefaultsManager.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//

import Foundation

//MARK: - UserDefaultManager
final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private let defaults: UserDefaults
    
    //Keys
    private let kSavedPreferenceDefaultsKey = "kSavedPreferenceDefaultsKey"
    private let kSavedUrlDefaultsKey = "kSavedUrlDefaultsKey"
    private let kAcceptedEulaDefaultsKey = "kAcceptedEulaDefaultsKey"
    private let kRouteDefaultsKey = "kRouteDefaultsKey"
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var preference: Preference? {
        get {
            guard let preference = defaults.value(forKey: kSavedPreferenceDefaultsKey) as? String else {
                return nil
            }
            return Preference(rawValue: preference)
        }
        set(environment) {
            defaults.set(environment?.rawValue, forKey: kSavedPreferenceDefaultsKey)
        }
    }
    
    func setRoute(to route: String?) {
        defaults.setValue(route, forKey: kRouteDefaultsKey)
    }
    
    func getRoute() -> String?
    {
        return defaults.string(forKey: kRouteDefaultsKey)
    }
    
    func setUrl(to url: String?) {
        print(url)
        defaults.setValue(url, forKey: kSavedUrlDefaultsKey)
    }
    
    func loadUrl() -> String? {
        return defaults.string(forKey: kSavedUrlDefaultsKey)
    }
    
    func isEualaAccepted() -> Bool {
        return defaults.bool(forKey: kAcceptedEulaDefaultsKey)
    }
    
    func acceptEuala() {
        defaults.setValue(true, forKey: kAcceptedEulaDefaultsKey)
    }
    
}

