//
//  ARCinemaView.swift
//  BrightCinema
//
//  Created by NSFuntik on 4.08.2023.
//

import SwiftUI

struct ARCinemaView: View {
    @StateObject var arVM: ARCinemaViewModel = ARCinemaViewModel()
    @State var showAlert = false
    @State var showImagePicker = false
    @State var isPicked : Bool = false
    @State var pulsate = false
    @State var cinemaURLString = ""
    @State var alertText = "Enter cinema link"
    var body: some View {
        VStack {
            HStack(alignment: .bottom ) {
                Text("AR Cinema")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                Spacer()
            }.padding(10)
                .frame(height: 80)
            Spacer()
            Section {
                VStack(alignment: .center, spacing: 20, content: {
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        HStack {
                            Image("PhotoLibrary")
                                .resizable()
                                .scaledToFit()
                            Text("Choose from Photo Library")
                        }.foregroundColor(.white)
                    })
                    .frame(height: 30, alignment: .center)
                    .padding(10)
                    .background{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2.0)
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width - 40)
                        
                    }.padding(.horizontal, 20)
                    
                    Button(action: {
                        alertText = "Enter cinema link"
                        showAlert = true
                        
                    }, label: {
                        HStack {
                            Image("Link")
                                .resizable()
                                .scaledToFit()
                            Text("Enter Web Link")
                        }.foregroundColor(.white)
                    })
                    .frame(height: 30, alignment: .center)
                    .padding(10)
                    .background{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2.0)
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width - 40)
                    }.padding(.horizontal, 20)
                })
            } header: {
                Text("Here you can choose source of your AR content:")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 23, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
            }
            Section {
                VStack(alignment: .center, spacing: 20, content: {
                    Image("preview")
                        .resizable()
                        .scaledToFill()
                        .disabled(true)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40, idealHeight: 230)
                        .cornerRadius(13)
                        .shadow(color: .secondary.opacity(0.5), radius: 3, x: 1, y: 1)
                        .padding(.horizontal, 10)
                        .padding()
                        .overlay {
                            
                            Image("film-reel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundStyle(.white)
                                .opacity(0.9)
                                .scaleEffect(self.pulsate ? 1.35 : 1)
                                .animation(self.pulsate ? Animation.easeInOut (duration: 1).repeatForever(autoreverses: true) : Animation.default, value: self.pulsate)
                                .task {
                                    self.pulsate = true
                                }
                        }
                        .onTapGesture {
                            cinemaURLString = "https://www.apple.com/105/media/us/apple-vision-pro/2023/7e268c13-eb22-493d-a860-f0637bacb569/films/product/vision-pro-product-tpl-us-2023_16x9.m3u8"
                            openAR()
                            
                        }
                })
            } header: {
                Text("or try with this one:")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 23, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
            }
            Spacer()
            
        }
        .backport.background({
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4411281645, green: 0.2581070364, blue: 0.7888512015, alpha: 1)),Color(#colorLiteral(red: 0.4036906362, green: 0.6013564467, blue: 0.9182696939, alpha: 1))]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
        })
        .sheet(isPresented: $showImagePicker, onDismiss: openAR, content: {
            ImagePicker(isShown: self.$showImagePicker, inputURL: $cinemaURLString, isPicked: $isPicked)
        })
        .alert(alertText, isPresented: $showAlert) {
            TextField("Enter cinema URL", text: $cinemaURLString)
            Button("Submit", action: openAR)
            Button("Cancel", role: .cancel, action: {
                showAlert = false
            })
        }
    }
    
    func openAR() {
        //            /*ARViewController*/.videoURL = inputURL
        guard let cinemaURL = URL(string: cinemaURLString) else {
            alertText = "Bad URL!"
            showAlert = true
            return
        }
        let vc = ARViewController()
        vc.videoURL = cinemaURL
        vc.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
}

import AVKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isShown : Bool
    @Binding var inputURL : String
    @Binding var isPicked : Bool
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoExportPreset = AVAssetExportPresetPassthrough
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        //Update UIViewcontrolleer Method
    }
    func makeCoordinator() -> ImagePickerCordinator {
        return ImagePickerCordinator(isShown: $isShown, inputURL: $inputURL, isPicked: $isPicked)
    }
    
}

class ImagePickerCordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isShown : Bool
    @Binding var isPicked : Bool
    //    let comltetion: ()->Void
    @Binding var inputURL : String
    init(isShown : Binding<Bool>, inputURL: Binding<String>, isPicked : Binding<Bool>) {
        _isShown = isShown
        _inputURL = inputURL
        _isPicked = isPicked
    }
    //Selected Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //        let uiImage = info[UIImagePickerController.InfoKey.] as! UIImage
        guard let videoURL = info[.mediaURL] as? URL else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        inputURL = videoURL.absoluteString
        //        let
        
        //        DispatchQueue.main.asyncAfter(deadline: .now()) {
        
        //        }
        //        print(inputURL!)
        
        isShown = false
        isPicked = true
        //        image = Image(uiImage: uiImage)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        isPicked = false
        
    }
}
