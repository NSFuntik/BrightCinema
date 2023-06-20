//
//  HomeViewModel.swift
//  cinema
//
//  Created by NSFuntik on 20.06.2023.
//

import SwiftUI
import Combine


class HomeViewModel: ObservableObject {
    let client = Service()
    var cancelRequest: Bool = false
    @Published var upcomingMovies: [Movie] = []
    @Published var celebritiesMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var trendingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []

    init() {
        loadUpcomingData()
        loadCelebrities()
        loadNowPlayingData()
        loadTrendingData()
        loadPopularData()
    }
    
    private func loadPopularData(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.TOP_RATED, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {

                let result = MovieResults.decode(jsonData: jsonData)
                if let movieResults = result?.results {
                    
                    DispatchQueue.main.async {
                        self.popularMovies += movieResults
                    }
                }
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return

                    }
                    self.loadPopularData(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: Double(retry), repeats: false, block: { (_) in
                        print("Retrying...")
                        guard !self.cancelRequest else { return }
                        self.loadPopularData(onPage: page)
                        return
                    })
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
    
    private func loadUpcomingData(onPage page: Int = 1) {
        
        guard !cancelRequest else { return }
        
        let _ = client.taskForGETMethod(Methods.UPCOMING, parameters: [ParameterKeys.PAGE: page as AnyObject, ParameterKeys.REGION: "US" as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                
                let result = MovieResults.decode(jsonData: jsonData)
                
                if let movieResults = result?.results {
                    
                    DispatchQueue.main.async {
                        self.upcomingMovies += movieResults
                    }
                }
                if let totalPages = result?.total_pages, page < totalPages {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return
                        
                    }
                    self.loadUpcomingData(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    self.loadUpcomingData(onPage: page)
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
    private func loadCelebrities(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.POPULAR_ACTORS, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                
                let result = MovieResults.decode(jsonData: jsonData)
                
                if let movieResults = result?.results {
                    
                    DispatchQueue.main.async {
                        self.celebritiesMovies += movieResults
                    }
                }
                
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Total Pages Actors: \(totalPages)")
                        print("Cancel Request Failed")
                        return
                        
                    }
                    self.loadCelebrities(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: Double(20), repeats: false, block: { (_) in
                        print("Retrying...")
                        guard !self.cancelRequest else { return }
                        self.loadCelebrities(onPage: 1)
                        return
                    })
                   
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
    
    private func loadNowPlayingData(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.NOW_PLAYING, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                let result = MovieResults.decode(jsonData: jsonData)
                if let movieResults = result?.results {
                    DispatchQueue.main.async {
                        self.nowPlayingMovies += movieResults
                    }
                }
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return

                    }
                    self.loadNowPlayingData(onPage: page + 1)
                }
                
                
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: Double(20), repeats: false, block: { (_) in
                        print("Retrying...")
                        guard !self.cancelRequest else { return }
                        self.loadNowPlayingData(onPage: page)
                        return
                    })
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
    
    private func loadTrendingData(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.TRENDING_WEEK, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                let result = MovieResults.decode(jsonData: jsonData)
                if let movieResults = result?.results {
                    
                    DispatchQueue.main.async {
                        self.trendingMovies += movieResults
                    }
                }
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return
                        
                    }
                    self.loadTrendingData(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: Double(20), repeats: false, block: { (_) in
                        print("Retrying...")
                        guard !self.cancelRequest else { return }
                        self.loadTrendingData(onPage: page)
                        return
                    })
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
}
