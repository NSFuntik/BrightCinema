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
            ScrollView {
                VStack {
                    ForEach($videosVM.videos, id: \.id) { $file in
                        let path = "\(Api.LOGIN_URL)\(file.path)"
                        if let url = URL(string: path) {
                            let vp = AVPlayer(url: url)
                            @State var isPresented = false
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
                                            downloader.downloadFile(with: file.path)
                                        } label: {
                                            Label("Download to internal drive", systemImage: "tray.and.arrow.down")
                                        }
                                        Button {
                                            isPresented = true
                                        } label: {
                                            Label("Enter Picture in Picture", systemImage: "arrow.up.backward.and.arrow.down.forward")
                                        }
                                        Button(role: .destructive) {
                                            OperationQueue.main.addOperation {
                                                videosVM.videos = videosVM.videos.filter({$0.uuid != file.uuid})
                                                videosVM.deleteFile(uuid: file.uuid)
                                            }
                                        } label: {
                                            Label("Remove file", systemImage: "trash.fill")
                                        }
                                    }))
                            } header: {
                                HStack {
                                    Spacer()
                                    Text(file.title ?? "")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.accentColor)
                                        .padding(.trailing, 5)
                                }.padding(.bottom, -15)
                            }
                        }
                    }
                    
                }
            }
            .refreshable {
                withAnimation {

                    videosVM.fetchUserVideos()
                }
            }
            .toolbar {
                NavigationLink {
                    DownloadedVideosView()
                } label: {
                    Image(systemName: "tray.full")
                        .foregroundColor(Color("AccentColor"))
                }

                Button(action: {
                    OperationQueue.main.addOperation {
                        videosVM.showingAlert = true
                    }
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AccentColor"))
                })
            }
            .sheet(isPresented: $videosVM.showingAlert, content: {
                VStack(alignment: .center, spacing: 10) {
                    Text("Enter URL and preferred title")
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 10)
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                    Text("Video will be downloaded to the server, \nso then you can watch it here.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    TextField("Enter title for video here", text: $videosVM.title)
                        .multilineTextAlignment(.center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.2)

                                .fill(Color.accentColor)
                        }.padding(.horizontal, 20)
                    
                    TextEditor(text: $videosVM.url)
                        .keyboardType(.URL)
                        .textContentType(.URL)
//                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(10).background{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.2)

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
                                .font(.system(size: 17, weight: .regular, design: .rounded))
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

                }.padding(.horizontal, 10)
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
        }.tint(Color("AccentColor"))
    }
    
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

