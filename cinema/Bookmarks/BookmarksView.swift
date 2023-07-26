//
//  BookmarksView.swift
//  cinema
//
//  Created by NSFuntik on 23.06.2023.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject var bookmarksVM = BookmarksViewModel()
    @State private var movieTitles: [String] = ["Hey! That's my watch list!"]
    @State private var isShareSheetPresented = false
    @State private var activityItems: [Any] = []
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
                                CachedAsyncImage(url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                    .appendingPathComponent(ImageKeys.PosterSizes.ORIGINAL_POSTER)
                                    .appendingPathComponent(posterPath)) {
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
        }.toolbar{
            if #available(iOS 16.0, *) {
                ShareLink(item: movieTitles.joined(separator: "\n ✔︎ "))
                    .task {
                        movieTitles = self.bookmarksVM.movies.compactMap {
                            return $0.title
                        }
                        movieTitles.insert("Hey! Check out my watchlist!", at: 0)
                    }
            }


//            Button(action: {
//                defer {
//                    isShareSheetPresented = true
//                }
//                
//                activityItems.append()
//            }, label: {
//                Image(systemName: "square.and.arrow.up.fill")
//            })
        }
        .sheet(isPresented: $isShareSheetPresented) {
            var items = activityItems
            ActivityViewController(activityItems: items)
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
