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
    
    
    let client = Service()
    
    init() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                self.idfa = ASIdentifierManager.shared().advertisingIdentifier
            case .notDetermined, .restricted, .denied:
                let keychain = Keychain(service: "dev.timmychoo.cinema")
                let uuid = UUID()
                keychain["idfa"] = uuid.uuidString
                self.idfa = uuid
                print("Unknown")
            @unknown default:
                break
            }
        }
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
    
    func isUsernameUnique(_ username: String) async {
        guard let isUnique = try? await client.isUsernameUnique(username: self.username) else { return }
        OperationQueue.main.addOperation {
            self.isUnique = isUnique
        }
    }
}




//SignInWithAppleButton(.signIn) { request in
//    // 1
//    request.requestedScopes = [.fullName, .email]
//} onCompletion: { result in
//    switch result {
//    case .success (let authResults):
//        // 2
//        print("Authorization successful.")
//        guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
//            signInVM.isAuthenticated = false
//            return
//        }
//        let userIdentifier = appleIDCredential.user
//
//        //                            YourBackendAPI.login(username: username, password: userIdentifier) { result in
//        //                                    switch result {
//        //                                    case .success(let accessKey):
//        //                                        // Save the access key to the keychain
//        //                                        let keychain = Keychain(service: "com.example.yourapp")
//        //                                        keychain["accessKey"] = accessKey
//        //
//        //                                        signInSucceeded(true)
//        //                                    case .failure:
//        //                                        signInSucceeded(false)
//        //                                    }
//        //                            }
//    case .failure (let error):
//        // 3
//        print("Authorization failed: " + error.localizedDescription)
//    }
//}.signInWithAppleButtonStyle(.white).frame(width: 280, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).cornerRadius(30).padding().disabled(signInVM.username.isEmpty)
//Section {
//    VStack(alignment: .center, spacing: 10) {
//        TextField("Username", text: $signInVM.username)
//            .font(.system(size: 20, weight: .medium, design: .rounded))
//            .padding(10)
//            .multilineTextAlignment(.center)
//            .background(RoundedRectangle(cornerRadius: 20.0).stroke(lineWidth: 1.0).foregroundColor(.white.opacity(0.75)))
//            .frame(width: 280, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            .onChange(of: signInVM.username) { newValue in
//                Task {
//                    await signInVM.isUsernameUnique(newValue)
//                }
//            }
//            .modifier(ShakeEffect(animatableData: CGFloat(signInVM.invalidAttempts)))
//        if !signInVM.username.isEmpty {
//            Text(!signInVM.username.isEmpty && signInVM.isUnique && signInVM.username.count >= 5  ? "Username is correct!" : "This username is incorrect or already exist!")
//                .font(.system(size: 17, weight: .medium, design: .rounded))
//                .multilineTextAlignment(.center)
//                .foregroundColor(signInVM.isUnique && signInVM.username.count >= 5 ? .green : .red)
//        }
//    }
//} header: {
//    VStack(alignment: .center) {
//        Text("Please type your username to continue")
//            .font(.system(size: 17, weight: .light, design: .rounded))
//        Text("(Minimum 5 symbols)")
//            .font(.system(size: 14, weight: .light, design: .rounded))
//    }
//    .foregroundColor(.white)
//    .minimumScaleFactor(0.75)
//    .padding(3)
//}
