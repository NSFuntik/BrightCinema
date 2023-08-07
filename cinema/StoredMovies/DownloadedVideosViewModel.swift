//
//  DownloadedVideosViewModel.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import AVKit
import SwiftUI
final class DownloadedVideosViewModel: ObservableObject {
    @Published var videos: [Asset] = []
    @StateObject var downloader = DownloadManager()
    @Published var diskStatus = DiskStatus()
    
    init() {
        let files: [String: String] = UserDefaults.standard.dictionary(forKey: "downloadedFiles") as? [String: String] ?? [:]
        debugPrint(files)
        for file in files {
            if let asset = downloader.getVideoFileAsset(with: file.key) {
                OperationQueue.main.addOperation {
                    self.videos.append(Asset(title: file.value, avAsset: asset))
                }
            }
        }
        debugPrint(videos)
        
    }
    
    
}
