//
//  TVPageDetailView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI
import Combine
final class TVPageDetailViewModel: ObservableObject {
    @Published var trailers: [Videos] = []
    let client: Service
    var cancelRequest: Bool = false
    var tvID: Int
    init(client: Service, tvID: Int) {
        self.client = client
        self.tvID = tvID
        self.client.tvVideos(tvID: tvID) { (videos: VideoInfo) in
            if let allVideos = videos.results{
                DispatchQueue.main.async {
                    self.trailers = allVideos
                }
            }
        }
    }
}
struct TVPageDetailView: View {
    @Binding var show: Movie
    @StateObject var detailVM: TVPageDetailViewModel
    var body: some View {
        
        VStack {
            if let posterPath = show.poster_path {
                AsyncImage(
                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER).appendingPathComponent(posterPath),
                    content: {
                        
                        $0
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height / 3)
                    }, placeholder: { Text("Loading ...") }
                )
                
                .scaledToFill()
                .cornerRadius(0)
            }
            HStack {
                Text(show.name ?? "")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                Spacer()
                if let rating = show.vote_average, rating != 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressBar(progress: .constant(rating)).scaledToFit().frame(width: 100, height: 100, alignment: .center)
                        }
                    }
                }
            }.frame(height: 100).padding(.vertical, -20)
            Section {
                
                ScrollView {
                    Text(show.overview ?? "")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }.padding(.horizontal, 5)
            } header: {
                VStack {
                    HStack {
                        Text("Overview")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider()
                }.padding(.bottom, -5)
            }
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach($detailVM.trailers, id: \.id) { trailer in
                            if let video_key = trailer.wrappedValue.key, let videoThumbURL = detailVM.client.youtubeThumb(path: video_key) {
                                
                                AsyncImage(
                                    url: videoThumbURL,
                                    content: { image in
                                        ZStack {
                                            image.resizable()
                                                .scaledToFill()
                                                .cornerRadius(10)
                                                .frame(height: UIScreen.main.bounds.height / 5).padding(5)
                                                .cornerRadius(10)
                                            Image("playButton")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 45, height: 45)
                                        }
                                        .onTapGesture {
                                            let videoURL = detailVM.client.youtubeURL(path: video_key)
                                            if let videourl = videoURL, let YTShort =  URL(string: "youtube://watch?v=\(video_key)") {
                                                if UIApplication.shared.canOpenURL(YTShort) {
                                                    UIApplication.shared.open(YTShort)
                                                } else {
                                                    UIApplication.shared.open(videourl)
                                                }
                                            }
                                        }
                                    }, placeholder: { Text("Loading ...") })
                                
                                
                                
                            }
                            
                        }
                    }
                }
            } header: {
                VStack {
                    HStack {
                        Text("Trailers")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider()
                }.padding(.bottom, -5)
            }
            
            
            
        }
        
        
        
    }
}

