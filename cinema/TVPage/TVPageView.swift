//
//  TVPageView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI

struct TVPageView: View {
    @ObservedObject var tvPageVM = TVPageViewModel()
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                TabView {
                    ForEach($tvPageVM.shows, id: \.id) { $show in
                        if let posterPath = show.poster_path {
                            NavigationLink {
                                TVPageDetailView(detailVM: TVPageDetailViewModel(client: tvPageVM.client, movie: show, isTV: true))
                            } label: {
                               CachedAsyncImage(
                                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                        .appendingPathComponent(ImageKeys.PosterSizes.ORIGINAL_POSTER)
                                        .appendingPathComponent(posterPath),
                                    content: { $0.resizable() },
                                    placeholder: { LoaderView(tintColor: Color("AccentColor")) }
                                )
                                .scaledToFill()
                                .cornerRadius(10)
                            }
                        }
                    }
                    .rotationEffect(.degrees(-90)) // Rotate content
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                }
                .frame(
                    width: proxy.size.height, // Height & width swap
                    height: proxy.size.width
                )
                .rotationEffect(.degrees(90), anchor: .topLeading) // Rotate TabView
                .offset(x: proxy.size.width) // Offset back into screens bounds
                .tabViewStyle(
                    PageTabViewStyle(indexDisplayMode: .always)
                )
            }
        }.frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        ).ignoresSafeArea(.all)
        
    }
}

struct TVPageView_Previews: PreviewProvider {
    static var previews: some View {
        TVPageView()
    }
}
