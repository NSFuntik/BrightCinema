//
//  DownloadManager.swift
//  BrightCinema
//
//  Created by NSFuntik on 26.07.2023.
//

import Foundation

import AVKit

final class DownloadManager: ObservableObject {
    @Published var isDownloading = false
    @Published var isDownloaded = false
    @Published var alertText = ""

    func downloadFile(with path: String) {
        print("downloadFile")
        isDownloading = true
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent(path)
        debugPrint(destinationUrl)
        var files: [String] = UserDefaults.standard.stringArray(forKey: "downloadedFiles") ?? []
       
        if let destinationUrl = destinationUrl {
//            if files.contains(path) {
//                self.alertText = "File already exist!"
//                self.isDownloaded = true
//            } else {
                if (FileManager().fileExists(atPath: destinationUrl.path)) {
                    print("File already exists")
                    isDownloading = false
                } else {
                    let urlRequest = URLRequest(url: URL(string: "\(Api.LOGIN_URL)\(path)")!)
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
//                                    try FileManager.default.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: false)
                                    try FileManager.default.createFile(atPath: destinationUrl.absoluteString, contents: data)
                                    try data.write(to: destinationUrl, options: [])

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
        
                files.append(path)
                UserDefaults.standard.set(files, forKey: "downloadedFiles")
//            }
        }
    }

    func deleteFile(with path: String) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(path)
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                print("File deleted successfully")
                isDownloaded = false
            } catch let error {
                print("Error while deleting video file: ", error)
            }
            if var files: [String] = UserDefaults.standard.array(forKey: "downloadedFiles") as? [String] {
                files = files.filter({$0 != path})
                UserDefaults.standard.set(files, forKey: "downloadedFiles")
            }
        }
    }

    func checkFileExists(with path: String) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(path)
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

    func getVideoFileAsset(with path: String) -> AVPlayerItem? {
        debugPrint("getVideoFileAsset with: \(path)")
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(path)
        debugPrint("destinationUrl : \(destinationUrl)")

        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                let avAssest = AVAsset(url: destinationUrl)
                
                return AVPlayerItem(asset: avAssest)
                
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
