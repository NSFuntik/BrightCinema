//
//  ContentView.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//

import SwiftUI

struct LaunchView: View {

    @AppStorage("kSavedUrlDefaultsKey") var url: String?

    @State var isPresented = false
    var body: some View {
        VStack {
            Image("apppreview")
                .resizable()
                .scaledToFill()
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center).ignoresSafeArea(.all)
        .fullScreenCover(isPresented: $isPresented) {
            ContentView().preferredColorScheme(.dark)
        }
    }
}
