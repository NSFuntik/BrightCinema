//
//  TVPageDetailView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI
import Combine
import OpenAI
final class TVPageDetailViewModel: ObservableObject {
    @Published var trailers: [Videos] = []
    let client: Service
    var cancelRequest: Bool = false
    @Published var movie: Movie
    @Published var quiz: QuizResult? = nil
    @Published var bookmarks = UserDefaults.standard.array(forKey: "Bookmarks") as? [Int] ?? [Int]()
    init(client: Service, movie: Movie, isTV: Bool = false) {
        self.client = client
        self.movie = movie
        if !isTV {
            self.client.movieDetail(movieID: movie.id!) { (movieRes:Movie) in
                DispatchQueue.main.async {
                    self.movie = movieRes
                }
            }
        }
        self.client.tvVideos(tvID: movie.id!) { (videos: VideoInfo) in
            if let allVideos = videos.results {
                DispatchQueue.main.async {
                    self.trailers = allVideos
                    
                }
            }
        }
        getQuiz()
    }
    
    func getQuiz() {
        if let movieName = self.movie.name ?? self.movie.title {
            Task {
                let quiz = try await self.client.getQuiz(forMovieNamed: movieName)
                DispatchQueue.main.async {
                    self.quiz = quiz
                }
            }
        }
    }
    
    //Runtime
    
}
struct TVPageDetailView: View {
    @State var isQuizPresented: Bool = false
    @State var quizText = ""
    @StateObject var detailVM: TVPageDetailViewModel
    let openAI = OpenAI(apiToken: "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")
    var body: some View {
        
        VStack {
            if let posterPath = $detailVM.movie.wrappedValue.poster_path {
                AsyncImage(
                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER).appendingPathComponent(posterPath),
                    content: {
                        $0
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height / 2.5)
                    },
                    placeholder: { LoaderView(tintColor: Color("AccentColor")) }
                )
                
                .scaledToFill()
                .cornerRadius(0)
            }
            HStack {
                
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(($detailVM.movie.wrappedValue.name ?? $detailVM.movie.wrappedValue.title) ?? "")
                        .lineLimit(2)
                        .font(.system(size: 23, weight: .semibold, design: .serif))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 10)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.leading, 5)
                    
                    if let releaseDate = $detailVM.movie.wrappedValue.release_date?.convertDateString() {
                        Text("**Release Date:** \(releaseDate)")
                            .font(.system(size: 14, weight: .light, design: .rounded))
                            .foregroundColor(Color.white)
                            .padding(.leading, 10)
                    }
                    if let runtime = $detailVM.movie.wrappedValue.runtime {
                        Text("**Runtime:** \(runtime) min")
                            .font(.system(size: 14, weight: .light, design: .rounded))
                            .padding(.bottom, 10)
                            .foregroundColor(Color.white)
                            .padding(.leading, 10)
                    }
                    
                }
                Spacer()
                if let rating = $detailVM.movie.wrappedValue.vote_average, rating != 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressBar(progress: .constant(rating)).scaledToFit().frame(width: 100, height: 100, alignment: .center)
                        }
                    }.frame(width: 100, height: 100, alignment: .center)
                }
            }.frame(height: 100).padding(.vertical, -20)
            
            
            
            if !detailVM.trailers.isEmpty {
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
                                        }, placeholder: { LoaderView(tintColor: Color("AccentColor")) })
                                }
                            }
                        }
                    }
                } header: {
                    VStack {
                        HStack {
                            Text("Trailers")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color("AccentColor"))
                                .padding(.leading, 5)
                            Spacer()
                        }.padding(.bottom, -5)
                        Divider().background(Color("AccentColor"))
                    }.padding(.bottom, -5)
                }
            }
            Section {
                ScrollView {
                    Text($detailVM.movie.wrappedValue.overview ?? "")
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.white)
                    
                }.padding(.horizontal, 5)
            } header: {
                VStack {
                    HStack {
                        Text("Overview")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color("AccentColor"))
                            .padding(.leading, 5)
                        
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider().background(Color("AccentColor"))
                }.padding(.bottom, -5)
            }
            if detailVM.quiz != nil  {
                NavigationLink {
                    MovieQuizView(quizVM: QuizViewModel(quiz: detailVM.quiz!),
                                  posterPath: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER).appendingPathComponent(detailVM.movie.poster_path!))
                } label: {
                    HStack {
                        Spacer()
                        Text("Take quiz about movie")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                        Spacer()
                    }.padding(10).background{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2.0)
                            .fill(Color.accentColor)
                    }.padding(.horizontal, 20)
                }.padding(.bottom, 20)
            } else {
                LoaderView(tintColor: Color("AccentColor"), scaleSize: 1).padding(.bottom, 20)
            }
        }.ignoresSafeArea(.all)//.background(Color("Blue"))
            .toolbar {
                if detailVM.trailers.isEmpty {
                    Button {
                        if detailVM.bookmarks.contains(detailVM.movie.id!) {
                            detailVM.bookmarks = detailVM.bookmarks.filter({$0 != detailVM.movie.id!})
                        } else {
                            detailVM.bookmarks.append(detailVM.movie.id!)
                        }
                        UserDefaults.standard.set(detailVM.bookmarks, forKey: "Bookmarks")
                        
                    } label: {
                        Image(systemName: detailVM.bookmarks.contains(detailVM.movie.id!) ? "bookmark.fill" :  "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25, alignment: .center)
                            .foregroundColor(detailVM.bookmarks.contains(detailVM.movie.id!) ? .red : .accentColor)
                    }
                }
                //                var bookmarks = UserDefaults.standard.array(forKey: "Bookmarks") as? [Int] ?? [Int]()
                
            }
    }
}

