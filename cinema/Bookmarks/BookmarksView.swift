//
//  BookmarksView.swift
//  cinema
//
//  Created by NSFuntik on 23.06.2023.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject var bookmarksVM = BookmarksViewModel()
    var body: some View {
        VStack {
            Spacer()
            if bookmarksVM.movies.isEmpty {
                Text("There is no saved movies or shows yet.\n You can add it in \"Movies\" Tab")
                    .font(.system(size: 20, weight: .light, design: .rounded))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            List {
                ForEach($bookmarksVM.movies, id: \.id) { $movie in
                    if let posterPath = movie.poster_path {
                        NavigationLink {
                            TVPageDetailView(detailVM: TVPageDetailViewModel(client: bookmarksVM.client, movie: movie))
                        } label: {
                            HStack(alignment: .top, spacing: 5) {
                                AsyncImage(url: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.ORIGINAL_POSTER).appendingPathComponent(posterPath)) {
                                    $0.resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 100, alignment: .center)
                                } placeholder: {
                                    LoaderView(tintColor: Color("AccentColor"))
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(movie.title ?? movie.name ?? "")")
                                        .font(.system(size: 17, weight: .semibold, design: .serif))
                                    Text("\(movie.release_date?.convertDateString() ?? "")")
                                        .font(.system(size: 14, weight: .light, design: .rounded))
                                }
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    DispatchQueue.main.async {
                        self.bookmarksVM.movies.remove(atOffsets: indexSet)
                        self.bookmarksVM.bookmarks.remove(atOffsets: indexSet)
                        UserDefaults.standard.set(self.bookmarksVM.bookmarks, forKey: "Bookmarks")
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
}

