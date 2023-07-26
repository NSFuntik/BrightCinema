//
//  BookmarksViewModel.swift
//  cinema
//
//  Created by NSFuntik on 28.06.2023.
//

import Foundation

final class BookmarksViewModel: ObservableObject {
    @Published var bookmarks = UserDefaults.standard.array(forKey: "Bookmarks") as? [Int] ?? [Int]()
    @Published var movies: [Movie] = []
    let client = Service()
    init() {
        getMovies()
    }
    
    func getMovies() {
        for bookmarkID in bookmarks {
            Task {
                if let movie = try? await client.movieDetail(movieID: bookmarkID) {
                    DispatchQueue.main.async {
                        self.movies.append(movie)
                    }
                }
            }
        }
    }
}
