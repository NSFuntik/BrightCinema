//
//  TVPageDetailViewModel.swift
//  cinema
//
//  Created by NSFuntik on 28.06.2023.
//

import Combine
import OpenAI
import Foundation
final class TVPageDetailViewModel: ObservableObject {
    @Published var trailers: [Trailer] = []
    let client: Service
    private var cancelRequest: Bool = false
    @Published var movie: Movie
    @Published var quiz: QuizResult? = nil
    @Published var bookmarks = UserDefaults.standard.array(forKey: "Bookmarks") as? [Int] ?? [Int]()
    @Published var aiOverview: String = ""
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
        self.client.tvVideos(tvID: movie.id!) { (videos: TrailersDTO) in
            if let allVideos = videos.results {
                DispatchQueue.main.async {
                    self.trailers = allVideos
                    
                }
            }
        }
        getQuiz()
        getOverview()
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
    
    func getOverview() {
        if let movieName = self.movie.name ?? self.movie.title {
            Task {
                if let aiOverview = try await self.client.getOverview(forMovieNamed: movieName) {
                    DispatchQueue.main.async {
                        self.aiOverview = aiOverview
                    }
                }
            }
        }
    }
}
