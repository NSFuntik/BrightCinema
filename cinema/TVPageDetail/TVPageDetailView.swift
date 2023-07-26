//
//  TVPageDetailView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI

struct TVPageDetailView: View {
    @State private var selectedRating: Int = 0
    @State private var isQuizPresented: Bool = false
    @State var quizText = ""
    @StateObject var detailVM: TVPageDetailViewModel
    @State var aiOverview = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if let posterPath = $detailVM.movie.wrappedValue.poster_path {
                        CachedAsyncImage(
                            url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                .appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER)
                                .appendingPathComponent(posterPath),
                            content: {
                                $0
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: UIScreen.main.bounds.height / 2.5)
                            },
                            placeholder: { LoaderView(tintColor: Color("AccentColor")).frame(height: UIScreen.main.bounds.height / 2.5) }
                        )
                        .scaledToFill()
                        .cornerRadius(0)
                        .padding(.horizontal, -10)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(($detailVM.movie.wrappedValue.name ?? $detailVM.movie.wrappedValue.title) ?? "")
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                                .minimumScaleFactor(0.7)
                                .padding(.top, 10)
                                .foregroundColor(Color("AccentColor"))
                            
                            if let releaseDate = $detailVM.movie.wrappedValue.release_date?.convertDateString() {
                                Text("**Release Date:** \(releaseDate)")
                                    .font(.system(size: 16, weight: .light, design: .rounded))
                                    .foregroundColor(Color.white)
                            }
                            if let runtime = $detailVM.movie.wrappedValue.runtime {
                                Text("**Runtime:** \(runtime) min")
                                    .font(.system(size: 16, weight: .light, design: .rounded))
                                    .padding(.bottom, 10)
                                    .foregroundColor(Color.white)
                            }
                            if let genres = detailVM.movie.genre_ids  {
                                Text("**Genres:** \(genres.map { TVGenre(rawValue: $0)?.list ?? "" }.joined(separator: ", "))")
                                    .font(.system(size: 16, weight: .light, design: .rounded))
                                    .padding(.bottom, 10)
                                    .foregroundColor(Color.white)
                                    .fixedSize(horizontal: false, vertical: true)
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
                    }.frame(height: 100)
                    Section {
                        RatingReviewView(rrVM: RatingReviewViewModel(client: detailVM.client, movieId: detailVM.movie.id ?? 0))
                    } header: {
                        VStack {
                            HStack {
                                Text("Rating & Reviews")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                                Spacer()
                            }.padding(.bottom, -2.5)
                            Divider().background(Color("AccentColor"))
                        }.padding(.bottom, -5)
                    }
                    if !detailVM.trailers.isEmpty {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach($detailVM.trailers, id: \.id) { trailer in
                                        if let video_key = trailer.wrappedValue.key, let videoThumbURL = detailVM.client.youtubeThumb(path: video_key) {
                                            CachedAsyncImage(
                                                url: videoThumbURL,
                                                content: { image in
                                                    ZStack {
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .cornerRadius(10)
                                                            .frame(height: UIScreen.main.bounds.height / 5).padding(5)
                                                            .cornerRadius(10)
                                                        Image("film-reel")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 45, height: 45)
                                                            .foregroundColor(Color("AccentColor"))
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
                                                }, placeholder: { LoaderView(tintColor: Color("AccentColor")) .frame(height: UIScreen.main.bounds.height / 5).padding(5)
                                                    .cornerRadius(10) })
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
                                    Spacer()
                                }.padding(.bottom, -2.5)
                                Divider().background(Color("AccentColor"))
                            }.padding(.bottom, -5)
                        }
                    }
                    Section {
                        ScrollView {
                            Text($detailVM.movie.wrappedValue.overview ?? "")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color.white)
                        }
                    } header: {
                        VStack {
                            HStack {
                                Text("Overview")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                                Spacer()
                            }.padding(.bottom, -2.5)
                            Divider().background(Color("AccentColor"))
                        }.padding(.bottom, -5)
                    }
                    Section {
                        ScrollView {
                            if aiOverview.isEmpty {
                                VStack(alignment: .leading) {
                                    Capsule()
                                        .frame(width: 300, height: 10)
                                    Capsule()
                                        .frame(width: 250, height: 10)
                                    Capsule()
                                        .frame(width: 200, height: 10)
                                    Capsule()
                                        .frame(width: 275, height: 10)
                                    Capsule()
                                        .frame(width: 300, height: 10)
                                }
                                .foregroundColor(Color.secondary.opacity(0.5))

                            } else {
                                
                                Text(aiOverview)
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color.white)
                            }
                        }
                    } header: {
                        VStack {
                            HStack {
                                Text("How thinks AI?")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                                Spacer()
                            }.padding(.bottom, -2.5)
                            Divider().background(Color("AccentColor"))
                        }.padding(.bottom, -5)
                    }
                    .onChange(of: detailVM.aiOverview) { newValue in
                        if !newValue.isEmpty {
                            typeWriter()
                        }
                    }
                }.padding(.horizontal, 10)
                Spacer(minLength: 200)
            }
            if detailVM.quiz != nil  {
                ZStack {
                    NavigationLink {
                        MovieQuizView(quizVM: QuizViewModel(quiz: detailVM.quiz!),
                                      posterPath: URL(string: ImageKeys.IMAGE_BASE_URL)!
                            .appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER)
                            .appendingPathComponent(detailVM.movie.poster_path ?? ""))
                    } label: {
                        ZStack {
                            HStack {
                                Spacer()
                                Text("Take quiz about movie")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Text("Powered by AI")
                                        .font(.system(size: 10, weight: .light, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                }.padding(.bottom, -5)
                            }
                        }.frame(height: 30, alignment: .center)
                            .padding(10).background{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2.0)
                                    .fill(Color.accentColor)
                            }.padding(.horizontal, 20)
                    }.padding(.bottom, 20)
                }
            } else {
                ZStack {
                    HStack {
                        Spacer()
                        LoaderView(tintColor: Color("AccentColor"), scaleSize: 1)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("Powered by AI")
                                .font(.system(size: 10, weight: .light, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        }.padding(.bottom, -5)
                    }
                }.frame(height: 30, alignment: .center)
                    .padding(10).background{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2.0)
                            .fill(Color.accentColor)
                    }.padding(.horizontal, 20).padding(.bottom, 20)
            }
        }
        //        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
        //            if(value.startLocation.x < 20 && value.translation.width > 100) {
        //                self.mode.wrappedValue.dismiss()
        //            }
        //
        //        }))
        .ignoresSafeArea(.container)
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
        }
    }
    
    func typeWriter(at position: Int = 0) {
        if position == 0 {
            aiOverview = ""
        }
        if position < detailVM.aiOverview.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                aiOverview.append(detailVM.aiOverview[position])
                typeWriter(at: position + 1)
            }
        }
    }
}

