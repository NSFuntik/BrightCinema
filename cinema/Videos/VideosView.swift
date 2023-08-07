//
//  VideosView.swift
//  BrightCinema
//
//  Created by NSFuntik on 25.07.2023.
//

import SwiftUI
import AVKit
import Combine
import SwiftUIBackports

struct VideosView: View {
    @StateObject var videosVM = VideosViewModel()
    @StateObject var downloader = DownloadManager()
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom ) {
                Text("My Library")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                Spacer()
                HStack(alignment: .top, spacing: 15) {
                    NavigationLink {
                        DownloadedVideosView()
                    } label: {
                        VStack(spacing: 3) {
                            Image("StoredMovies")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color("AccentColor"))
                                .frame(width: 30, height: 30, alignment: .center)
                            Text("Stored")
                                .font(.system(size: 11, weight: .light, design: .rounded))
                        }
                    }
                    
                    Button(action: {
                        OperationQueue.main.addOperation {
                            videosVM.showingAlert = true
                        }
                    }, label: {
                        VStack(spacing: 3) {
                            Image("AddMovie")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color("AccentColor"))
                                .frame(width: 30, height: 30, alignment: .center)
                            Text("Upload")
                                .font(.system(size: 11, weight: .light, design: .rounded))
                            
                        }
                    })
                }
            }.padding(10)
            .frame(height: 80)
//            ProgressView(value: 512, total: 10240) {
//                HStack(alignment: .center, spacing: 5) {
//                    Image("CloudDisk")
//                        .resizable()
//                        .frame(width: 30, height: 30, alignment: .center)
//                        .scaledToFit()
//                    Text("Cloud Storage")
//                        .font(.system(size: 17, weight: .regular, design: .rounded))
//                        .foregroundStyle(.white)
//                    Spacer()
//                    Text("Total: 10 GB")
//                        .font(.system(size: 15, weight: .light, design: .rounded))
//                        .foregroundStyle(.secondary)
//
//                }
//            } currentValueLabel: {
//                Text("Avaible Cloud Disk space: \(10240 - 512) MB")
//                    .font(.system(size: 15, weight: .light, design: .rounded))
//                    .foregroundStyle(.secondary)
//                
//            }
//            .progressViewStyle(LinearProgressViewStyle())
//            .padding(15)

            ScrollView {
                VStack {
                    ForEach($videosVM.videos, id: \.id) { $file in
//                        let path = "\(Api.LOGIN_URL)\(file.path)"
                        if let url = URL(string:  file.url) {
                            let vp = AVPlayer(url: url)
                            @State var isPresented = false
                            VStack {
                                Section {
                                    PlayerViewController(player: vp)
                                        .frame(maxWidth: .infinity, idealHeight: 230)
                                        .cornerRadius(13)
                                        .shadow(color: .secondary.opacity(0.5), radius: 3, x: 1, y: 1)
                                        .padding(.horizontal, 10)
                                        .padding()
                                        .pipify(isPresented: $isPresented)
                                    
                                        .contextMenu(ContextMenu(menuItems: {
                                            Button {
                                                downloader.downloadFile(with: file.name ?? "", path:  file.url)
                                            } label: {
                                                Label("Download", image: "download")
                                            }
                                            
                                            Button(role: .destructive) {
                                                OperationQueue.main.addOperation {
                                                    videosVM.videos = videosVM.videos.filter({$0.uuid != file.uuid})
                                                    videosVM.deleteFile(uuid: file.uuid)
                                                }
                                            } label: {
                                                Label("Remove", systemImage: "trash")
                                            }
                                        }))
                                } footer: {
                                    HStack(alignment: .lastTextBaseline) {
                                        
                                        Text(file.name ?? "")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color.accentColor)
                                            .minimumScaleFactor(0.7)
                                        Spacer()
                                        if let releaseDate = getDate(from: file.createdAt ?? "2023-08-01T10:32:56.666Z") {
                                            let createdInterval = Calendar(identifier: .iso8601).numberOfDaysBetween(releaseDate, and: .now)
                                            Text("\(createdInterval) days ago")
                                                .font(.system(size: 14, weight: .light, design: .rounded))
                                                .foregroundColor(Color.secondary)
                                        }
                                        
                                        Menu {
                                            Button {
                                                downloader.downloadFile(with: file.name ?? "", path:  file.url)
                                            } label: {
                                                Label("Download", image: "download")
                                            }
                                            
                                            Button(role: .destructive) {
                                                OperationQueue.main.addOperation {
                                                    videosVM.deleteFile(uuid: file.uuid)
                                                    withAnimation {
                                                        videosVM.videos = videosVM.videos.filter({$0.uuid != file.uuid})
                                                    }
                                                }
                                            } label: {
                                                Label("Remove", systemImage: "trash")
                                            }
                                        }
                                    label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 23, weight: .thin, design: .rounded))
                                            .rotationEffect(Angle(degrees: 90.0)).offset(x: 10, y: 0)
                                            .padding(.leading, -10)
                                            .frame(width: 25, height: 25, alignment: .trailing)
                                    }
                                        
                                        
                                    }.padding(.top, -15) .padding(.horizontal, 25)
                                }
                                Divider().background(Color("AccentColor").opacity(0.5)) .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                }
            }
          
            .toolbar {
                NavigationLink {
                    DownloadedVideosView()
                } label: {
                    Image("StoredMovie")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 30, height: 30, alignment: .center)
                }
                
                Button(action: {
                    OperationQueue.main.addOperation {
                        videosVM.showingAlert = true
                    }
                }, label: {
                    Image("AddMovie")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 30, height: 30, alignment: .center)
                })
                
            }
        }.tint(Color("AccentColor")).blur(radius: videosVM.showingAlert ? 2 : 0)
            .refreshable {
                withAnimation {
                    
                    videosVM.fetchUserVideos()
                }
            }
            .sheet(isPresented: $videosVM.showingAlert, content: {
                VStack(alignment: .center, spacing: 10) {
                    Text("UPLOAD YOUR MOVIE")
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 10)
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                    Text("Enter URL and title.\nVideo will be downloaded to the server, \nso then you can watch it here.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    TextField("Enter title for video here", text: $videosVM.title)
                        .multilineTextAlignment(.center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.3)
                            
                                .fill(Color.accentColor)
                        }.padding(.horizontal, 20)
                    
                    TextEditor(text: $videosVM.url)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .multilineTextAlignment(.center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.3)
                            
                                .fill(Color.accentColor)
                        }.padding(.horizontal, 20)
                        .frame(minHeight: 100)
                    Button(action: self.videosVM.submit) {
                        HStack {
                            Spacer()
                            Text("Submit")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        .frame(height: 30, alignment: .center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AccentColor"))
                        }.padding(.horizontal, 20)
                    }
                    Button(action: { videosVM.showingAlert = false }) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("AccentColor"))
                            Spacer()
                        }
                        .frame(height: 30, alignment: .center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1.0)
                            
                                .fill(Color.accentColor)
                        }.padding(.horizontal, 20)
                    }
                    
                }.padding(10)
                    .backport.presentationDetents([.medium])
                    .backport.presentationDragIndicator(.visible)
                
            })
        
            .alert(videosVM.alertMessage, isPresented: $videosVM.showingResult) {
                Button("Cool!", role: .cancel) {
                    OperationQueue.main.addOperation {
                        videosVM.showingResult = false
                    }
                }.disabled(videosVM.title.isEmpty || videosVM.url.isEmpty)
            }
            .alert(downloader.alertText, isPresented: $downloader.isDownloaded) {
                Button("OK!", role: .cancel) {
                }
            }
    }
    
    //    struct TooltipView: Tip {
    //        var title: Text =
    //
    //        var body: some View {
    //            VStack {
    //                Text("Here you can add & upload your preffered movies or videos from URL").font(.title)
    //                Text("Video will be downloaded to the server, so then you can watch it here or download on device.").font(.subheadline)
    //
    //            }
    //        }
    //    }
    
}
struct PlayerViewController: UIViewControllerRepresentable {
    //    var videoURL: URL?
    
    var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.allowsPictureInPicturePlayback = true
        controller.player = player
        controller.showsPlaybackControls = true
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.showsTimecodes = true
        
        return controller
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.showsPlaybackControls = true
        playerController.allowsPictureInPicturePlayback = true
        playerController.modalPresentationStyle = .fullScreen
        playerController.entersFullScreenWhenPlaybackBegins = true
        
        
    }
    
}

