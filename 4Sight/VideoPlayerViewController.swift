//
//  VideoPlayerViewController.swift
//  4Sight
//
//  Created by Simon Withington on 16/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerViewController: AVPlayerViewController {

    var videoURL: URL?
    var callback: (()->())?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let player = player, player.status == .readyToPlay {
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
            
            player.play()
        }
    }
    
    func loadVideo() {
        
        if let videoURL = videoURL {
            self.player = AVPlayer(url: videoURL)
        }
    }
    
    func playerDidFinishPlaying(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self)
        callback?()
    }
}
