//
//  SignInViewModel.swift
//  BrightCinema
//
//  Created by NSFuntik on 11.07.2023.
//

import Foundation
import AdSupport
import AppTrackingTransparency
import KeychainAccess


final class SignInViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var username = ""
    @Published var idfa: UUID = ASIdentifierManager.shared().advertisingIdentifier
    @Published var isUnique = false
    @Published var invalidAttempts = 0
    private let keychain = Keychain(service: "dev.timmychoo.cinema")
    private let client = Service()
    
    init() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                self.idfa = ASIdentifierManager.shared().advertisingIdentifier
            case .notDetermined, .restricted, .denied:
                let uuid = UUID()
                self.idfa = uuid
                print("Unknown")
            @unknown default:
                break
            }
        }
        self.keychain["idfa"] = self.idfa.uuidString

    }
    
    func login(password: String) async {
        do {
            let accessToken = try await client.auth(accessType: AccessType.LOGIN,
                                                    username: self.username,
                                                    fingerprint: self.idfa,
                                                    password: password)
            let keychain = Keychain(service: "dev.timmychoo.cinema")
            keychain["accessKey"] = accessToken
            keychain["userID"] = password
            
            OperationQueue.main.addOperation {
                self.isAuthenticated = true
//                UIApplication.shared.keyWindow?.rootViewController = UIHostingController(rootView: ContentView().tint(Color("AccentColor")))
            }
        }
        catch {
            debugPrint(error.localizedDescription)
            switch error {
            case NetworkError.invalidCredentials:
                OperationQueue.main.addOperation {
                    self.invalidAttempts += 1
                }
            default:
                OperationQueue.main.addOperation {
                    self.isAuthenticated = false
                }
            }
        }
    }
}
