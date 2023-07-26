//
//  HomeView.swift
//  cinema
//
//  Created by NSFuntik on 20.06.2023.
//

import SwiftUI
import Combine

var imageCache = NSCache<AnyObject, AnyObject>()

struct HomeView: View {
    @StateObject var homeVM: HomeViewModel = HomeViewModel()
    
    @ViewBuilder
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                upcomingMoviesTabs
                    .frame(height: UIScreen.main.bounds.height / 3, alignment: .center).layoutPriority(1)
                celebitiesList
                
                MoviesListView(movies: $homeVM.nowPlayingMovies, title: "Now Playing", client: homeVM.client)
                MoviesListView(movies: $homeVM.trendingMovies, title: "Trending", client: homeVM.client)
                MoviesListView(movies: $homeVM.popularMovies, title: "Top Rated", client: homeVM.client)
            }
        }
    }
    
    private struct MoviesListView: View {
        @Binding var movies: [Movie]
        let title: String
        let client: Service
        
        var body: some View {
            Section {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach($movies, id: \.id) { $movie in
                            if let posterPath = movie.poster_path {
                                NavigationLink {
                                    TVPageDetailView(detailVM: TVPageDetailViewModel(client: client, movie: movie))
                                } label: {
                                   CachedAsyncImage(
                                        url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                            .appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER)
                                            .appendingPathComponent(posterPath),
                                        content: {
                                            $0
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                                .frame(height: 150, alignment: .center)
                                                .padding(5)
                                        },
                                        placeholder: { LoaderView(tintColor: Color("AccentColor")).clipShape(RoundedRectangle(cornerRadius: 13)).shadow(color: .gray, radius: 3, x: 0, y: 3)
                                                .frame(height: 150, alignment: .center)
                                                .padding(5) })
                                }
                            }
                        }
                    }
                }.padding(.horizontal, 5).shadow(color: .gray, radius: 3, x: 0, y: 3)
                    
            } header: {
                VStack {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .padding(.leading, 5)
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider().background(Color("AccentColor"))
                }.padding(.bottom, -5)
            }
            
            
        }
    }
     
    var upcomingMoviesTabs: some View {
        TabView {
            ForEach($homeVM.upcomingMovies, id: \.id) { movie in
                if let posterPath = movie.wrappedValue.backdrop_path {
                    NavigationLink {
                        TVPageDetailView(detailVM: TVPageDetailViewModel(client: homeVM.client, movie: movie.wrappedValue))
                    } label: {
                       CachedAsyncImage(
                            url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                .appendingPathComponent(ImageKeys.PosterSizes.BACK_DROP)
                                .appendingPathComponent(posterPath),
                            content: {
                                $0.resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width,
                                           height: UIScreen.main.bounds.height / 3, alignment: .center)
                                    .overlay {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Spacer()
                                            HStack {
                                                Text((movie.wrappedValue.name ?? movie.wrappedValue.title) ?? "")
                                                    .font(.system(size: 23, weight: .semibold, design: .serif))
                                                    .multilineTextAlignment(.leading)
                                                    .minimumScaleFactor(0.7)
                                                Spacer()
                                            }
                                            if let releaseDate = movie.wrappedValue.release_date?.convertDateString() {
                                                Text("Release Date: \(releaseDate)")
                                                    .font(.system(size: 14, weight: .light, design: .rounded))
                                            }
                                        }.padding(5)
                                    }
                            }, placeholder: {
                                LoaderView(tintColor: Color("AccentColor"))
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .center)
                            }
                        )
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .center)
                    }
                }
            }
        }
        .tabViewStyle(
            PageTabViewStyle(indexDisplayMode: .always)
        )
    }
    
    var celebitiesList: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach($homeVM.celebritiesMovies, id: \.id) { $celebrity in
                        if let posterPath = celebrity.profile_path {
                            NavigationLink {
                                ActorDetailView(actorDetailVM: ActorDetailViewModel(actorID: celebrity.id!, client: homeVM.client))
                            } label: {
                               CachedAsyncImage(
                                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER).appendingPathComponent(posterPath),
                                    content: {
                                        $0
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 75, height: 75)
                                            .padding(5)
                                    },
                                    placeholder: {
                                        LoaderView(tintColor: Color("AccentColor"))
                                            .clipShape(Circle())
                                            .frame(width: 75, height: 75)
                                            .padding(5)
                                    })
                            }
                        }
                    }
                }
            }.padding(.horizontal, 5).shadow(color: .gray.opacity(0.75), radius: 3, x: 0, y: 3)
        } header: {
            VStack {
                HStack {
                    Text("Popular Celebrities")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .padding(.leading, 5)
                    
                    Spacer()
                }.padding(.bottom, -5)
                Divider().background(Color("AccentColor"))
            }.padding(.bottom, -5)
        }
    }
}
