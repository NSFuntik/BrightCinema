//
//  DownloadManager.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import Foundation
import VidLoader
import AVKit

final class DownloadManager: ObservableObject {
    @Published var isDownloading = false
    @Published var isDownloaded = false
    @Published var alertText = ""
    private let vidLoader = VidLoader()
    func downloadFile(with title: String, path: String) {
        print("downloadFile")
        isDownloading = true
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent("/Uploads").appendingPathComponent(URL(string: path)!.lastPathComponent)
        debugPrint(destinationUrl)
        var files: [String: String] = UserDefaults.standard.dictionary(forKey: "downloadedFiles") as? [String: String] ?? [:]
        debugPrint(destinationUrl?.pathExtension)
        if destinationUrl?.pathExtension == "m3u8" {
            files[path] = title
            vidLoader.download(DownloadValues(identifier: URL(string: path)!.lastPathComponent, url: URL(string: path)!, title: title))
            UserDefaults.standard.set(files, forKey: "downloadedFiles")
            self.isDownloading = false
            self.alertText = "Downloaded!"
            self.isDownloaded = true
            print("Downloaded!")

        } else  {
            if files.keys.contains(path) {
                self.alertText = "File already exist!"
                self.isDownloaded = true
            } else {
                if (FileManager().fileExists(atPath: destinationUrl!.path)) {
                    print("File already exists")
                    isDownloading = false
                } else {
                    let urlRequest = URLRequest(url: URL(string: path)!)
                    debugPrint(urlRequest)

                    let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

                        if let error = error {
                            print("Request error: ", error)
                            self.isDownloading = false
                            return
                        }

                        guard let response = response as? HTTPURLResponse else { return }

                        if response.statusCode == 200 {
                            guard let data = data else {
                                self.isDownloading = false
                                return
                            }
                            DispatchQueue.main.async {
                                do {
                                    try FileManager.default.createDirectory(at: destinationUrl!.deletingLastPathComponent(), withIntermediateDirectories: true)
                                    debugPrint(destinationUrl!.relativePath)
                                   _ = FileManager.default.createFile(atPath: destinationUrl!.relativePath, contents: data)
//                                    try data.write(to: destinationUrl, options: [])
                                    
                                    DispatchQueue.main.async {
                                        self.isDownloading = false
                                        self.alertText = "Downloaded!"
                                        self.isDownloaded = true
                                        print("Downloaded!")

                                    }
                                } catch let error {
                                    print("Error decoding: ", error)
                                    self.isDownloading = false
                                    self.alertText = error.localizedDescription
                                    self.isDownloaded = true

                                    
                                }
                            }
                        }
                    }
                    dataTask.resume()
                }
        
                files[URL(string: path)!.lastPathComponent] = title
                UserDefaults.standard.set(files, forKey: "downloadedFiles")
            }
        }
        
    }

    func deleteFile(with path: String) {
//        
//        if let url = URL(string: path), url.pathExtension == "m3u8" {
//            
////            resume(identifier: url.lastPathComponent)
//        } else  {
            
            let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            let destinationUrl = docsUrl?.appendingPathComponent("/Uploads").appendingPathComponent(path)
            if let destinationUrl = destinationUrl {
                guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
                do {
                    try FileManager().removeItem(atPath: destinationUrl.path)
                    var files: [String: String] = UserDefaults.standard.dictionary(forKey: "downloadedFiles") as? [String: String] ?? [:]
                    guard files[path] != nil else { return }
                    files[path] = nil
                    debugPrint(files)
                    UserDefaults.standard.set(files, forKey: "downloadedFiles")
                    print("File deleted successfully")
                    isDownloaded = false
                } catch let error {
                    print("Error while deleting video file: ", error)
                }
                
                
            }
//        }
    }

    func checkFileExists(with path: String) {
        if let url = URL(string: path), url.pathExtension == "m3u8" {
            isDownloaded =  vidLoader.asset(location: url) != nil ?  true : false
        } else {
            
            let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            let destinationUrl = docsUrl?.appendingPathComponent("/Uploads").appendingPathComponent(path)
            if let destinationUrl = destinationUrl {
                if (FileManager().fileExists(atPath: destinationUrl.path)) {
                    isDownloaded = true
                } else {
                    isDownloaded = false
                }
            } else {
                isDownloaded = false
            }
        }
    }

    func getVideoFileAsset(with path: String) -> AVAsset? {
        debugPrint("getVideoFileAsset with: \(path)")
        if let url = URL(string: path), url.pathExtension == "m3u8" {
            return vidLoader.asset(location: url)
        } else {
            
            let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            let destinationUrl = docsUrl?.appendingPathComponent("/Uploads").appendingPathComponent(path)
            debugPrint("destinationUrl : \(destinationUrl?.absoluteString ?? "NOT FOUND")")
            
            if let destinationUrl = destinationUrl {
                if (FileManager().fileExists(atPath: destinationUrl.path)) {
                    return AVAsset(url: destinationUrl)
                    
                    //                return AVPlayerItem(asset: avAssest)
                    
                } else {
                    debugPrint("file DON'T Exists at \(destinationUrl)")
                    
                    return nil
                }
            } else {
                debugPrint("destinationUrl : NIL")
                
                return nil
            }
        }
    }
}
