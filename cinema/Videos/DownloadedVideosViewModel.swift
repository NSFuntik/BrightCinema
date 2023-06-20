//
//  DownloadedVideosViewModel\.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import Foundation

final class DownloadedVideosViewModel: ObservableObject {
    @Published var videos: [AVPlayerItem] = []
    @ObservedObject var downloadManager: DownloadManager
    
    init(downloadManager: DownloadManager) {
        self.downloadManager = downloadManager
        let paths = UserDefaults.standard.stringArray(forKey: "downloadedFiles")
        paths.map { path in
            videos.append(downloadManager.getVideoFileAsset(with: path))
        }
        
    }
    
    
}
