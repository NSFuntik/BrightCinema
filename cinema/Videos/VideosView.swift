//
//  VideosView.swift
//  BrightCinema
//
//  Created by NSFuntik on 25.07.2023.
//

import SwiftUI

struct VideosView: View {
    @StateObject var videosVM = VideosViewModel()
    var body: some View {
        Text("Hello, World!")
            .toolbar {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AccentColor"))
                })
            }
    }
}

#Preview {
    VideosView()
}
