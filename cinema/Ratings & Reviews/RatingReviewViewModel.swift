//
//  RatingReviewViewModel.swift
//  BrightCinema
//
//  Created by NSFuntik on 12.07.2023.
//

import Foundation
import KeychainAccess
final class RatingReviewViewModel: ObservableObject {
    let client: Service
    let movieId: Int
    let keychain = Keychain(service: "dev.timmychoo.cinema")
    @Published var reviews: [Review] = []
    @Published var selectedRating: Int = 0
    @Published var writtenReview: String = ""
    @Published var reviewsStatus: String = "No reviews yet."

    init(client: Service, movieId: Int) {
        self.client = client
        self.movieId = movieId
        fetchReviews()
    }
    
    func fetchReviews() {
        Task {
            do {
                if let reviews = try await client.fetchReviews(for: movieId) {
                    OperationQueue.main.addOperation {
                        self.reviews = reviews
                    }
                }
            } catch {
                switch error {
                case NetworkError.invalidCredentials:
                    OperationQueue.main.addOperation {
                        self.reviewsStatus = "Authentication expired. Please log in again."
                    }
                default:
                    OperationQueue.main.addOperation {
                        if self.keychain["accessKey"] == nil {
                            self.reviewsStatus = "You have to sign in to see reviews."
                        } else {
                            self.reviewsStatus = error.localizedDescription
                        }
                    }
                }
            }
           
        }
    }
    
    func submitReview() async {
        do {
            try await client.submitReview(cinemaId: movieId, rating: selectedRating, content: writtenReview)
            fetchReviews()
        }
        catch {
            debugPrint(error)
        }
        
    }
}
