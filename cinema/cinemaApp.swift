//
//  cinemaApp.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI

@main
struct cinemaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        OliLibrary(AppsFlyerId: "6450501413",
                   Keitaro: "https://ycmpuis.com/",
                   KeitaroId: "7D2PjGf5",
                   Privacy: "brightcinema_privacypolicy",
                   commonView: UIHostingController(rootView: ContentView()
                    .preferredColorScheme(.dark)
                    .tint(Color("AccentColor"))))
    }
    var body: some Scene {
        WindowGroup {
            LaunchView()//.preferredColorScheme(.dark)
        }
    }
}
