//
//  ActorDetailView.swift
//  cinema
//
//  Created by NSFuntik on 20.06.2023.
//

import SwiftUI

struct ActorDetailView: View {
    @StateObject var actorDetailVM: ActorDetailViewModel
    var body: some View {
        VStack {
            if let profile_path = $actorDetailVM.actor.wrappedValue.profile_path {
               CachedAsyncImage(
                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                        .appendingPathComponent(ImageKeys.PosterSizes.DETAIL_POSTER)
                        .appendingPathComponent(profile_path),
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
            }
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(($actorDetailVM.actor.wrappedValue.name ?? "None"))
                        .font(.system(size: 23, weight: .semibold, design: .serif))
                        .foregroundColor(Color("AccentColor"))
                        .minimumScaleFactor(0.7)
                        .padding(.leading, 5)
                    if let releaseDate = $actorDetailVM.actor.wrappedValue.birthday?.convertDateString() {
                        Text("**Birthday:** \(releaseDate)")
                            .font(.system(size: 14, weight: .light, design: .rounded))
                            .foregroundColor(Color.white)
                            .padding(.bottom, 5)
                            .padding(.leading, 10)
                    }
                }
                Spacer()
            }
            Section {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach($actorDetailVM.actorCast, id: \.id) { $cast in
                            if let posterPath = cast.poster_path {
                                NavigationLink {
                                    TVPageDetailView(detailVM: TVPageDetailViewModel(client: actorDetailVM.client,
                                                                                     movie: Movie(id: cast.id,
                                                                                                  title: nil, backdrop_path: nil, poster: nil, overview: nil, release_date: nil, video: nil, genre_ids: nil, popularity: nil, first_air_date: nil, name: nil),
                                                                                     isTV: false))
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
                                        placeholder: { LoaderView(tintColor: Color("AccentColor")) })
                                }
                            }
                        }
                    }
                }.padding(.horizontal, 5)
            } header: {
                VStack {
                    HStack {
                        Text("Actor's Cast")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color.accentColor)
                            .padding(.leading, 5)
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider().background(Color("AccentColor"))
                }.padding(.bottom, -5)
            }
            Section {
                ScrollView {
                    Text($actorDetailVM.actor.wrappedValue.biography ?? "")
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.white)
                }.padding(.horizontal, 5)
            } header: {
                VStack {
                    HStack {
                        Text("Biography")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color.accentColor)
                            .padding(.leading, 5)
                        
                        Spacer()
                    }.padding(.bottom, -5)
                    Divider().background(Color("AccentColor"))
                }.padding(.bottom, -5)
            }
            Spacer()
        }.ignoresSafeArea(.all)
    }
}


