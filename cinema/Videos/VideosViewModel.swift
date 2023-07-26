//
//  VideosViewModel.swift
//  BrightCinema
//
//  Created by NSFuntik on 25.07.2023.
//

import Foundation
import Combine

final class VideosViewModel: ObservableObject {
    private let client = Service()
    @Published var url: String = ""
    @Published var title: String = ""
    @Published var videos: [File] = []
    @Published var showingAlert: Bool = false
    @Published var showingResult: Bool = false
    @Published var alertMessage: String = "Success!\nAfter couple minutes video will be uploaded."
    init() {
       fetchUserVideos()
    }
    
    func deleteFile(uuid: String) {
        Task {
            try await client.deleteFile(uuid:uuid)
        }
    }
    
    func submit() {
        debugPrint("submiting video url: \(url)")
        showingAlert = false
        Task {
            do {
                try await client.submitVideo(url: url, title: title)
            }
            catch {
                alertMessage = (error as! NetworkError).desctiption
            }
        }
        OperationQueue.main.addOperation {
            self.showingResult = true
        }
    }
    
    func fetchUserVideos() {
        Task {
            do {
                self.videos = try await client.fetchUserVideos()
                debugPrint(self.videos)
            }
            catch {
               debugPrint(error as? NetworkError)
            }
        }
//        showingAlert = false
//        showingResult = true
    }
}
