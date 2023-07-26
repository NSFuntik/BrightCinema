//
//  ContentView.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//

import SwiftUI
import KeychainAccess

struct LaunchView: View {
    @State var isPresented = false
    var body: some View {
        VStack {
            Image("apppreview")
                .resizable()
                .scaledToFill()
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center).ignoresSafeArea(.all)
        .fullScreenCover(isPresented: $isPresented) {
            ContentView().tint(Color("AccentColor"))
        }
    }
}
