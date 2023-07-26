//
//  DownloadedVideosView.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import SwiftUI
import AVKit
struct DownloadedVideosView: View {
    @StateObject var downloadedVideosVM = DownloadedVideosViewModel()
    
    var body: some View {
        
        
        ScrollView {
            VStack {
                
                ForEach($downloadedVideosVM.videos, id: \.self) { $element in
                    
                    @State var isPresented = false
                    
                    PlayerViewController(player: AVPlayer(playerItem: AVPlayerItem(asset: element.asset)))
                        .frame(maxWidth: .infinity, idealHeight: 230)
                        .cornerRadius(13)
                        .shadow(color: .secondary.opacity(0.5), radius: 3, x: 1, y: 1)
                        .padding(.horizontal, 10)
                        .pipify(isPresented: $isPresented)
                        .contextMenu(ContextMenu(menuItems: {
                            Button(role: .destructive) {
                                OperationQueue.main.addOperation {
                                    //                                                downloadedVideosVM.videos = downloadedVideosVM.videos.filter({$0.uuid != file.uuid})
                                    var paths = UserDefaults.standard.stringArray(forKey: "downloadedFiles") ?? []
                                    if let index = downloadedVideosVM.videos.firstIndex(of: element) {
                                        downloadedVideosVM.downloader.deleteFile(with: paths[index])
                                        paths.remove(at: index)
                                    }
                                    
                                }
                            } label: {
                                Label("Remove file", systemImage: "trash.fill")
                            }
                        }))
                    
                }
            }
            
        }.navigationTitle("Downloaded")
        
        .tint(Color("AccentColor"))
    }
}

