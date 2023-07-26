//
//  TVPageViewModel.swift
//  cinema
//
//  Created by NSFuntik on 28.06.2023.
//

import Foundation
import Combine

final class TVPageViewModel: ObservableObject {
    @Published var shows: [Movie] = []
    let client = Service()
    private var cancelRequest: Bool = false
    
    init() {
        loadLatestTvData()
    }
    
    private func loadLatestTvData(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.TRENDING_TV, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                
                let result = MovieResults.decode(jsonData: jsonData)
                if let movieResults = result?.results {
                    DispatchQueue.main.async {
                        self.shows += movieResults
                    }
                }
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return
                        
                    }
                    self.loadLatestTvData(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                Timer.scheduledTimer(withTimeInterval: Double(retry), repeats: false, block: { (_) in
                    print("Retrying...")
                    guard !self.cancelRequest else { return }
                    self.loadLatestTvData(onPage: page)
                    return
                })
                
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
}
