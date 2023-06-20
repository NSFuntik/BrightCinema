//
//  ContentView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI

struct ContentView: View {
    @State var sideBar: SideMenu = SideMenu(selectedItem: .constant(.highlights), isSidebarVisible: .constant(false))
    @State private var isSideBarOpened = false
    @State var selectedItem: Tab = .highlights
    var body: some View {
        NavigationView {
            switch selectedItem {
            case .highlights:
                TVPageView().navigationTitle("Weekly highlights").navigationBarTitleDisplayMode(.inline).navigationBarHidden(true)
            case .main:
                HomeView().navigationTitle("Movies").navigationBarTitleDisplayMode(.inline).navigationBarHidden(true)
            case .search:
                SearchMovieView()
                    .navigationTitle("Search").navigationBarTitleDisplayMode(.inline)
            case .bookmarks:
                BookmarksView()
                    .navigationTitle("Bookmarks").navigationBarTitleDisplayMode(.inline)
            }
        }.layoutPriority(0.5)//.blur(radius: isSideBarOpened ? 3 : 0)
            
            .overlay {
                sideBar
//                    SideMenu(selectedItem: $selectedItem, isSidebarVisible: $isSideBarOpened).layoutPriority(1)
                    .onChange(of: selectedItem) { newValue in
                        print(selectedItem)
                        isSideBarOpened.toggle()
                    }
            }
            .onAppear {
                sideBar = SideMenu(selectedItem: $selectedItem, isSidebarVisible: $isSideBarOpened)
            }
        
    }
    
    struct SideMenu: View {
        @State var privacySheet = false
        @Binding var selectedItem: Tab
        @Binding var isSidebarVisible: Bool
        var sideBarWidth = UIScreen.main.bounds.size.width * 0.7
        var bgColor: Color = Color(.init(
                                      red: 52 / 255,
                                      green: 70 / 255,
                                      blue: 182 / 255,
                                      alpha: 1))

        var body: some View {
//            ZStack {
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
                
//            }
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
//                            SettingsScenesPrivate.global.privacyB = true
                            privacySheet = true
//                            let viewController = PrivacyViewController(nibName: nil, bundle: nil)
//                            viewController.modalPresentationStyle = .popover
//                            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true)
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.shield.checkmark")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
//                                    .foregroundColor(secondaryColor)
                                    .padding(.trailing, 18)
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                        
                        ShareLink(item: URL(string: "https://apps.apple.com/us/app/")!,
                        label : {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(secondaryColor)
                                        .padding(.trailing, 18)
                                    Text("Share app")
                                        .foregroundColor(.white)
                                        .font(.body)
                                }
                        })
                            
                        Button {
                            DispatchQueue.main.async {
                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//                                    SKStoreReviewController.requestReview(in: scene)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
//                                    .foregroundColor(secondaryColor)
                                    .padding(.trailing, 18)
                                Text("Rate us")
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                        
                    }
                    .padding(.top, 80)
                    .padding(.horizontal, 40)
                }
                .frame(width: sideBarWidth)
                .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
                .animation(.default, value: isSidebarVisible)

                Spacer()
            }.sheet(isPresented: $privacySheet) {
//                PrivacyView()
            }
        }

        var MenuChevron: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
//                Circle()
                    .fill(bgColor.opacity(isSidebarVisible ? 0 : 1))
                    .frame(width: 70, height: 70)
                    .rotationEffect(Angle(degrees: 45))
                    .offset(x: isSidebarVisible ? 0 : -10)
                 
//                    .opacity(0.4)
                Image("film-reel")
                    .foregroundColor(.accentColor)
                    .rotationEffect(isSidebarVisible ?
                        Angle(degrees: 180) : Angle(degrees: 0))
                    .offset(x: isSidebarVisible ? -20 : 12)
                    .foregroundColor(.blue)
            }   .onTapGesture {
                isSidebarVisible.toggle()
            }
            .offset(x: sideBarWidth / 2, y: 80)
            .animation(.default, value: isSidebarVisible)
        }

        var userProfile: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image("ico").resizable().scaledToFit().frame(width: 50, height: 50, alignment: .center).cornerRadius(10)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to Bright Movies!")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.75)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    struct MenuLinks: View {
        var items: [MenuItemBadge]
        @Binding var selectedItem: Tab
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(items) { item in
                    HStack {
                        Image(item.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.accentColor)
                            .padding(.trailing, 18)
                        Text(item.text)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .onTapGesture {
                            selectedItem = item.id
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.leading, 8)
        }
    }

    struct menuLink: View {
        @Binding var id: Tab
        var icon: String
        var text: String
        var body: some View {
            HStack {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                    .padding(.trailing, 18)
                Text(text)
                    .foregroundColor(.white)
                    .font(.body)
            }
        }
    }
}


