//
//  DownloadedVideosViewModel.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import AVKit
import SwiftUI
final class DownloadedVideosViewModel: ObservableObject {
    @Published var videos: [AVPlayerItem] = []
    @StateObject var downloader = DownloadManager()
    
    init() {
        let paths = UserDefaults.standard.stringArray(forKey: "downloadedFiles") ?? []
        debugPrint(paths)
        for path in paths {
            if let asset = downloader.getVideoFileAsset(with: path) {
                videos.append(asset)
            }
        }
        debugPrint(videos)
        
    }
    
    
}
