//
//  AppearVideoNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 09/07/2019.
//

import UIKit
import SceneKit
import AVKit

public class AppearVideoNode: SCNNode {
    
    public var plane: SCNPlane!
    public var avPlayer: AVPlayer!
    
    public init(videoArchiveURL: URL, media: AppearProjectItem.VideoMedia) {
        super.init()
        
        self.plane = SCNPlane(width: CGFloat(0.1), height: CGFloat(0.10 * 2.16))
        
        self.geometry = plane
        self.name = media.name
        //planeNode.eulerAngles.x = -.pi / 2
        
        let avPlayerItem = AVPlayerItem(url: videoArchiveURL)
        self.avPlayer = AVPlayer(playerItem: avPlayerItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.avPlayer.play()
        }
        
        if media.autoRepeat ?? false {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: nil,
                queue: nil) { notification in
                    self.avPlayer.seek(to: .zero)
                    self.avPlayer.play()
            }
        }
        
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avPlayer
        
        self.geometry?.materials = [avMaterial]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
