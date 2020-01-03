
//
//  VideoViewController.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 8/22/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    
    private var videoURL: URL?{
        didSet{
            self.view.backgroundColor = UIColor.gray
            player = AVPlayer(url: videoURL!)
            playerController = AVPlayerViewController()
            
            guard player != nil && playerController != nil else {
                return
            }
            playerController!.showsPlaybackControls = false
            
            playerController!.player = player!
            self.addChild(playerController!)
            self.view.addSubview(playerController!.view)
            playerController!.view.frame = view.frame
            playerController?.view.contentMode = UIView.ContentMode.scaleAspectFill
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
            
            let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
            cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State())
            
            cancelButton.addTarget(self, action: #selector(cancel1), for: .touchUpInside)
            view.addSubview(cancelButton)
              // Allow background audio to continue to play
            
            
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
                } else {
                }
            } catch let error as NSError {
                print(error)
            }
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
            
        }
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    @objc func cancel1() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

extension VideoViewController : CameraViewControllerDelegate {
    //used to pass url data from camera view controller 
    func didrecieveVideoURL(videoURL: URL) {
        self.videoURL = videoURL
        
    }
}
