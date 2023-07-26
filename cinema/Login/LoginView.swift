//
//  LoginView.swift
//  BrightCinema
//
//  Created by NSFuntik on 7.07.2023.
//

import SwiftUI
import AuthenticationServices
import SwiftUIBackports

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var signInVM = SignInViewModel()
    @State var text: String = ""
    @Binding var selectedItem: Tab
    @State var finalText: String = """
**- AI Description:**   Unique and in-depth movie descriptions created with AI.

**- AI Quizzes:**   Test your knowledge of the movie industry with the exciting quizzes.

**- Movie Watchlist:**  Build and share your own collection of movies and shows by adding them to watchlist.

**- Trailers Galore:**  Immerse yourself in the movie's world by watching thrilling trailers.

**- Cast Insights:**    Discover the stars behind the scenes with detailed information about the cast.

**- Movie Info Hub:**   Uncover a treasure trove of movie details, including title, genre, director, writer, and release date.

**- Reviews and Ratings:**  Make well-informed decisions by reading reviews and ratings from fellow movie enthusiasts.
"""
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image("ico").resizable().scaledToFit().frame(width: 100, height: 100, alignment: .center).cornerRadius(10)
                Text("Welcome to Bright Cinema!")
                    .foregroundColor(.white)
                    .bold()
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                Spacer()
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(
                            """
                            **- AI Description:**   Unique and in-depth movie descriptions created with AI.

                            **- AI Quizzes:**   Test your knowledge of the movie industry with the exciting quizzes.

                            **- Movie Watchlist:**  Build and share your own collection of movies and shows by adding them to watchlist.

                            **- Trailers Galore:**  Immerse yourself in the movie's world by watching thrilling trailers.

                            **- Cast Insights:**    Discover the stars behind the scenes with detailed information about the cast.

                            **- Movie Info Hub:**   Uncover a treasure trove of movie details, including title, genre, director, writer, and release date.

                            **- Reviews and Ratings:**  Make well-informed decisions by reading reviews and ratings from fellow movie enthusiasts.
                            """)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .light, design: .rounded))
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                 
                }
                Spacer()
                VStack {
                    SignInWithAppleButton(.signUp) { request in
                        // 1
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success (let authResults):
                            // 2
                            print("Authorization successful.")
                            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                                signInVM.isAuthenticated = false
                                
                                return
                            }
                            let userIdentifier = appleIDCredential.user
                            Task {
                                await signInVM.login(password: userIdentifier)
                            }
                            
                        case .failure (let error):
                            
                            debugPrint("Authorization failed: " + error.localizedDescription)
                        }
                    }.signInWithAppleButtonStyle(.white).frame(width: 280, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).cornerRadius(30).padding([.top, .horizontal])
                    Text("Autorization is required to access user's reviews")
                        .font(.system(size: 14, weight: .light, design: .rounded))
                }
            }
        }.padding(.horizontal, 20).frame(width: UIScreen.main.bounds.width)//
            .backport.background({
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4411281645, green: 0.2581070364, blue: 0.7888512015, alpha: 1)),Color(#colorLiteral(red: 0.4036906362, green: 0.6013564467, blue: 0.9182696939, alpha: 1))]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            })
            .onAppear(perform: {
                typeWriter()
            })
            .onChange(of: signInVM.isAuthenticated) {  newValue in
                if newValue == true {
                    selectedItem = .highlights
                }
            }
           
    }
    func typeWriter(at position: Int = 0) {
        if position == 0 {
            text = ""
        }
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                text.append(finalText[position])
                typeWriter(at: position + 1)
            }
        }
    }
}

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

