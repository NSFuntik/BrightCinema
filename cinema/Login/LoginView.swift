//
//  LoginView.swift
//  BrightCinema
//
//  Created by NSFuntik on 7.07.2023.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess

struct LoginView: View {
    @StateObject private var signInVM = SignInWithAppleViewModel()
    
    var body: some View {
        VStack {
            if signInVM.isAuthenticated {
                Text("Authenticated with Apple")
                    .font(.title)
                    .padding()
            } else {
                Button(action: {
                    signInVM.performSignIn()
                }) {
                    Text("Sign In with Apple")
                        .font(.title)
                        .padding()
                }
            }
        }
    }
}




class SignInWithAppleViewModel: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var username: String = ""
    func performSignIn() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
        
    }
}

extension SignInWithAppleViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            //            debugPrint(userIdentifier, userFirstName, userLastName, userEmail)
            //Navigate to other view controller
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle the error
        print("Sign in with Apple error: \(error.localizedDescription)")
    }
}

extension SignInWithAppleViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the window to present the Sign In with Apple dialog
        guard let window = UIApplication.shared.windows.first else {
            fatalError("No window scene available.")
        }
        return window
    }
}
