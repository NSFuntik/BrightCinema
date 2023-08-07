//
//  ViewController.swift
//  VideoProjector
//
//  Created by Mikhailov on 16.02.2021.
//

import UIKit
import RealityKit
import AVFoundation
import ARKit
import Vision
import CoreLocation
import CoreMotion
import SwiftUI
class ARViewController: UIViewController, CLLocationManagerDelegate, ARCoachingOverlayViewDelegate {
    var videoURL = URL(string: "")
    var arView: ARView  = ARView(frame: UIScreen.main.bounds)

    var videoPlayer: AVPlayer!
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(arView)
        guard let videoURL = videoURL else { return }
        let playerItem = AVPlayerItem(url: videoURL)
        
        let videoPlayer = AVPlayer(playerItem: playerItem)
        self.videoPlayer = videoPlayer
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.8, depth: 0.45), materials: [videoMaterial])
        
        let anchor = AnchorEntity(plane: .vertical)
        
        addCoaching()
        anchor.addChild(videoPlane)
        arView.scene.anchors.append(anchor)
        
        let rect1 = CGRect(x: 5, y: 35, width: 100, height: 50)
        let rect2 = CGRect(x: 70, y: 35, width: 100, height: 50)
        let rect3 = CGRect(x: 135, y: 35, width: 100, height: 50)
//        let rect4 = CGRect(x: 200, y: 25, width: 100, height: 50)
        
        // PLAY BUTTON
        let playButton = UIButton(frame: rect1)
        playButton.tintColor = .white
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        
        // STOP BUTTON
        let stopButton = UIButton(frame: rect2)
        stopButton.tintColor = .white
        stopButton.setImage(UIImage(systemName: "pause"), for: .normal)
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        
//        print(stopButton.imageView?.image?.size.height)
//        print(stopButton.imageView?.image?.size.width)
        let homeButton = UIButton(frame: rect3)
        homeButton.tintColor = .white
        homeButton.setImage(UIImage(systemName: "house.fill"), for: .normal)
        homeButton.addTarget(self, action: #selector(home), for: .touchUpInside)
        self.arView.addSubview(playButton)
        self.arView.addSubview(stopButton)
        self.arView.addSubview(homeButton)

        //        print(homeButton.imageView?.image?.size.height)
//        print(homeButton.imageView?.image?.size.width)
//        let VRButton = UIButton(frame: rect4)
//        VRButton.tintColor = .darkGray
////        var image = UIImage(named: "vr")
//        VRButton.setImage(UIImage(named: "vr"), for: .normal)
//        VRButton.addTarget(self, action: #selector(vr), for: .touchUpInside)
//        self.view.addSubview(VRButton)
//        print(VRButton.imageView?.image?.size.height)
//        print(VRButton.imageView?.image?.size.width)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    
    @objc func home(sender: UIButton!) {
        self.videoPlayer.pause()
        self.dismiss(animated: true) {
            self.videoPlayer = nil
//            self.arView = nil
        }
    }
    
    @objc func play(sender: UIButton!) {
        self.videoPlayer.play()
    }
    @objc func stop(sender: UIButton!) {
        self.videoPlayer.pause()
    }
    func addCoaching() {
        
        //Create a ARCoachingOverlayView object
        let coachingOverlay = ARCoachingOverlayView()
        
        //Make sure it rescales if the device orintation changes
        coachingOverlay.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        
//        arView.addSubview(coachingOverlay)
                view.addSubview(coachingOverlay)
        
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.goal = .verticalPlane
        
        coachingOverlay.fillSuperview()
    }
    @objc func loopVideo(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: CMTime.zero, completionHandler: nil)
        videoPlayer.play()
    }
}

let save = UserDefaults.standard

fileprivate extension ARView {
    
    func run() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
 
        session.run(config, options: [.removeExistingAnchors, .resetTracking]) //.resetSceneReconstruction
    }
    
    func pause() {
        session.pause()
    }
}

extension UIView {
    
    // MARK: Constraints
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    
    // MARK: Other
    
    var screenshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
}
