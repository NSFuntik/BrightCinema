//
//  ContentView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI
import StoreKit
import KeychainAccess
import SwiftUIBackports

struct ContentView: View {
    @State private var isLoggingIn = false
    @State var selectedItem: Tab = Keychain(service: "dev.timmychoo.cinema")["accessKey"] == nil ? .signIn : .highlights
    @State var isSidebarVisible: Bool = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @GestureState private var dragOffset = CGSize.zero
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor")?.withAlphaComponent(0.75) ?? .clear]
        UINavigationBar.appearance().isTranslucent = true
        //Use this if NavigationBarTitle is with displayMode = .inline
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor")?.withAlphaComponent(0.75) ?? .clear]

    }
    var body: some View {
        NavigationView {
            ZStack {
                
                switch selectedItem {
                case .highlights:
                    TVPageView()
                        .navigationTitle("Weekly highlights")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                case .main:
                    HomeView()
                        .navigationTitle("Movies")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                        .layoutPriority(0.5)
                case .search:
                    SearchMovieView()
                        .navigationTitle("Search")
                        .layoutPriority(0.5)
                        .navigationBarHidden(true)

//                        .navigationBarHidden(isSidebarVisible ? true : false)
                case .bookmarks:
                    BookmarksView()
                    
                        .navigationTitle("Bookmarks")
                        .layoutPriority(0.5)
                        .navigationBarHidden(true)

//                        .navigationBarHidden(isSidebarVisible ? true : false)
                case .signIn:
                    LoginView(selectedItem: $selectedItem)
                        .layoutPriority(0.5)
                        .navigationBarHidden(true)

//                        .navigationBarHidden(isSidebarVisible ? true : false)
                case .videos:
                    VideosView()
                        .navigationBarHidden(true)
//                        .navigationBarHidden(/*isSidebarVisible ?*/ true : false)
                        .layoutPriority(0.5)
                    
                case .arcinema:
                    ARCinemaView()
                        .navigationBarHidden(true)
//                        .navigationBarHidden(/*isSidebarVisible ?*/ true : false)
                        .layoutPriority(0.5)
                }
                
                SideMenu(selectedItem: $selectedItem, isSidebarVisible: $isSidebarVisible).layoutPriority(1.0)
                    .onChange(of: selectedItem) { newValue in
                        print(selectedItem)
                        isSidebarVisible.toggle()
                    }
                
            }
            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                if(value.startLocation.x < 20 && value.translation.width > 100) {
                    isSidebarVisible = true
                }
                
            }))
        }
        
        
    }
    
    private struct SideMenu: View {
        @State var privacySheet = false
        @Binding var selectedItem: Tab //= .highlights
        @Binding var isSidebarVisible: Bool //= false
        @State private var isDeletingAlert = false
        
        var sideBarWidth = UIScreen.main.bounds.size.width * 0.7
        var bgColor: Color = Color(.init(
            red: 52 / 255,
            green: 70 / 255,
            blue: 182 / 255,
            alpha: 1))
        
        var body: some View {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            .overlay {
                content
            }
            .edgesIgnoringSafeArea(.all)
        }
        
        var content: some View {
            HStack(alignment: .top) {
                ZStack(alignment: .top) {
                    bgColor.opacity(0.8)
                    MenuChevron
                    VStack(alignment: .leading, spacing: 20) {
                        userProfile
                        Divider().background(Color.white)
                        MenuLinks(items: userActions, selectedItem: $selectedItem)
                        Divider().background(Color.white)
                        Button {
                            isSidebarVisible = false
                            SettingsScenesPrivate.global.privacyB = true
                            privacySheet = true
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.shield.checkmark")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 18)
                                Text("Privacy Policy")
                                    .foregroundColor(Color(uiColor: UIColor.white))
                                    .font(.system(size: 16 , weight: .light, design: .rounded))
                            }
                        }
                        if #available(iOS 16.0, *) {
                            ShareLink(item: URL(string: "https://apps.apple.com/us/app/bright-cinema/id6450501413")!,
                                      label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 18)
                                    Text("Share app")
                                        .foregroundColor(Color(uiColor: UIColor.white))
                                        .font(.system(size: 16 , weight: .light, design: .rounded))
                                }
                            })
                        }
                        Button {
                            OperationQueue.main.addOperation {
                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "star")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 18)
                                Text("Rate us")
                                    .foregroundColor(Color(uiColor: UIColor.white))
                                    .font(.system(size: 16 , weight: .light, design: .rounded))
                            }
                        }
                        
                        Button {
                            OperationQueue.main.addOperation {
                                let keychain = Keychain(service: "dev.timmychoo.cinema")
                                keychain["accessKey"] = nil
                                keychain["userID"] = nil
                                UserDefaults.standard.set(nil, forKey: "downloadedFiles")
                                OperationQueue.main.addOperation {
                                    UIApplication.shared.keyWindow?.rootViewController = UIHostingController(rootView: LaunchView(isPresented: true))
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "door.left.hand.open")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 18)
                                Text("Log out")
                                    .foregroundColor(Color(uiColor: UIColor.white))
                                    .font(.system(size: 16 , weight: .light, design: .rounded))
                            }
                        }
                        Spacer()
                        Button {
                            OperationQueue.main.addOperation {
                                isDeletingAlert = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.fill.xmark")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 18)
                                    .font(.system(size: 16 , weight: .thin, design: .rounded))
                                
                                Text("Delete account")
                                    .foregroundColor(Color(uiColor: UIColor.white))
                                    .font(.system(size: 16 , weight: .thin, design: .rounded))
                            }
                        }.padding(.bottom, 40)
                    }
                    .padding(.top, 80)
                    .padding(.horizontal, 40)
                }
                .frame(width: sideBarWidth)
                .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
                .animation(.default, value: isSidebarVisible)
                
                Spacer()
            }.sheet(isPresented: $privacySheet) {
                PrivacyView()
            }
            .alert("Are you sure you wanna delete the account?", isPresented: $isDeletingAlert, actions: {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await Service.deleteUser()
                            
                            
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                    OperationQueue.main.addOperation {
                        UIApplication.shared.keyWindow?.rootViewController = UIHostingController(rootView: LaunchView(isPresented: true))
                    }
                } label: { Text("Delete") }
                Button(role: .cancel) {
                    isDeletingAlert = false
                } label: {
                    Text("Cancel")
                }
                
            }, message: {
                Text("You won't be able to see users rating & reviews.")
            })
            
        }
        
        var MenuChevron: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(bgColor.opacity(isSidebarVisible ? 0 : 0.75))
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: 45))
                    .offset(x: isSidebarVisible ? 0 : -10)
                
                Image("film-reel")
                    .foregroundColor(Color("AccentColor").opacity(isSidebarVisible ? 1 : 0.75))
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .rotationEffect(isSidebarVisible ?
                                    Angle(degrees: 180) : Angle(degrees: 0))
                    .offset(x: isSidebarVisible ? -20 : 17.5, y: isSidebarVisible ? -15 : 0)
            }
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            .offset(x: sideBarWidth / 2, y: 80)
            .animation(.default, value: isSidebarVisible)
        }
        
        var userProfile: some View {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Image("ico").resizable().scaledToFit().frame(width: 50, height: 50, alignment: .center).cornerRadius(10)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to Bright Cinema!")
                            .foregroundColor(Color(uiColor: UIColor.white))
                            .bold()
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.75)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    private struct MenuLinks: View {
        var items: [MenuItemBadge]
        @Binding var selectedItem: Tab
        let keychain = Keychain(service: "dev.timmychoo.cinema")
        
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(items) { item in
                    if item.id == .signIn, keychain["accessKey"] != nil {
                        
                    } else {
                        HStack {
                            Image(item.icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("AccentColor"))
                                .padding(.trailing, 18)
                            Text(item.text)
                                .foregroundColor(Color(uiColor: UIColor.white))
                                .font(.system(size: 17 , weight: item.id == selectedItem ? .semibold : .light, design: .rounded))
                                .opacity(item.id == selectedItem ? 1.0 : 0.7)
                            //                            .bold()
                        }
                        .onTapGesture {
                            selectedItem = item.id
                        }
                        
                    }
                    
                }
            }
            .padding(.vertical, 14)
            .padding(.leading, 8)
        }
    }
    
    private struct menuLink: View {
        @Binding var id: Tab
        var icon: String
        var text: String
        var body: some View {
            HStack {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.trailing, 18)
                Text(text)
                    .foregroundColor(Color(uiColor: UIColor.white))
                    .font(.system(size: 16 , weight: .light, design: .rounded))
            }
        }
    }
    
    private struct PrivacyView: UIViewRepresentable {
        func updateUIView(_ uiView: UIViewType, context: Context) { }
        func makeUIView(context: Context) -> some UIView {
            return PrivacyViewController(nibName: nil, bundle: nil).view
        }
    }
}



