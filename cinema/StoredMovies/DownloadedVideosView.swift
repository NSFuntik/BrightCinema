//
//  DownloadedVideosView.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import SwiftUI
import AVKit

struct Asset: Hashable {
    let title : String
    let avAsset : AVAsset
}

struct DownloadedVideosView: View {
    @StateObject var downloadedVideosVM = DownloadedVideosViewModel()
    private var files: [String: String] = UserDefaults.standard.dictionary(forKey: "downloadedFiles") as? [String: String] ?? [:]
    
    @State var isAlertPresented = false
    var body: some View {
        ScrollView {
            VStack {
                ProgressView(value: downloadedVideosVM.diskStatus.usedDiskSpaceInBytes.double, total: downloadedVideosVM.diskStatus.totalDiskSpaceInBytes.double) {
                    HStack(alignment: .center, spacing: 5) {
                        Image("Disk")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .scaledToFit()
                        Text("iPhone Storage")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("Total:  \(downloadedVideosVM.diskStatus.totalDiskSpace)")
                            .font(.system(size: 15, weight: .light, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                    }
                } currentValueLabel: {
                    Text("Avaible Disk Space: \(downloadedVideosVM.diskStatus.freeDiskSpace)")
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                }
                .padding(10)
                .progressViewStyle(LinearProgressViewStyle())
                ForEach(downloadedVideosVM.videos, id: \.self) { asset in
                    //                    let asset = downloadedVideosVM.videos[title]
                    VStack {
                        Section {
                            @State var isPresented = false
                            
                            PlayerViewController(player: AVPlayer(playerItem: AVPlayerItem(asset: asset.avAsset)))
                                .frame(maxWidth: .infinity, idealHeight: 230)
                                .cornerRadius(13)
                                .shadow(color: .secondary.opacity(0.5), radius: 3, x: 1, y: 1)
                                .pipify(isPresented: $isPresented)
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(role: .destructive) {
                                        if let path = files.findKey(forValue: asset.title) {
                                            OperationQueue.main.addOperation {
                                                downloadedVideosVM.videos = downloadedVideosVM.videos.filter({$0 != asset})
                                                self.downloadedVideosVM.downloader.deleteFile(with: path)
                                            }
                                        }
                                    } label: {
                                        Label("Remove file", systemImage: "trash.fill")
                                    }
                                }))
                        } header: {
                            HStack(alignment: .lastTextBaseline) {
                                
                                Text(asset.title )
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.accentColor)
                                Spacer()
                                Text("\(asset.avAsset.g_fileSize)")
                                    .font(.system(size: 14, weight: .light, design: .rounded))
                                    .foregroundColor(Color.secondary)
                            }
                        }
                        Divider().background(Color("AccentColor").opacity(0.5))
                            .padding(.vertical, 5)
                    }
                }
            }.padding(10)
            
        }.navigationTitle("Downloads").tint(Color("AccentColor"))
            .toolbar {
                Button {
                    isAlertPresented = true
                } label: {
                    Image(systemName: "paintbrush").rotationEffect(Angle(degrees: 180.0))
                }
                
            }
            .alert("Clear stored files?", isPresented: $isAlertPresented) {
                Button("Confirm", role: .destructive) {
                    files.keys.forEach { path in
                        downloadedVideosVM.downloader.deleteFile(with: path)
                    }
                    downloadedVideosVM.videos = []
                }
                Button("Cancel", role: .cancel) {
                    isAlertPresented = false
                }
            }
    }
}

extension Dictionary where Value: Equatable {
    func findKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
extension AVAsset {
    var g_fileSize: String {
        guard let avURLAsset = self as? AVURLAsset else { return "" }
        
        let result = try? avURLAsset.url.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize//.getResourceValue(&result, forKey: NSURLFileSizeKey)
        
        if let result = result as? NSNumber {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(truncating: result))
            print(string)
            return string
        } else {
            return ""
        }
        
    }
}
