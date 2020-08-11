//
//  AppearVideoNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 09/07/2019.
//

import UIKit
import SceneKit
import AVKit
import ARKit

@available(iOS 12.0, *)
public class AppearVideoNode: SCNNode {
    
    public var plane: SCNPlane!
    public var avPlayer: AVPlayer!
    
    public init(videoArchiveURL: URL, media: AppearProjectItem.VideoMedia, size: CGSize? = nil, anchor: ARAnchor) {
        super.init()
        
        self.plane = SCNPlane(width: CGFloat(size?.width ?? 0.1), height: CGFloat(size?.height ?? 0.10 * 2.16))
        
        self.geometry = plane
        self.name = media.name
        //planeNode.eulerAngles.x = -.pi / 2
        
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.X, .Y]
        self.constraints = [constraint]
        
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
        
        //MARK: - Position
        if let objectAnchor = anchor as? ARObjectAnchor {
            self.position = SCNVector3(objectAnchor.referenceObject.center.x + Float(media.position?[0] ?? 0.0),
                                            objectAnchor.referenceObject.center.y + Float(media.position?[1] ?? 0.0),
                                            objectAnchor.referenceObject.center.z + Float(media.position?[2] ?? 0.0))
        } else if let imageAnchor = anchor as? ARImageAnchor {
            let imageSize = imageAnchor.referenceImage.physicalSize
            switch media.contentMode {
            case .scaleToFill:
                self.plane.width = CGFloat(imageSize.width)
                self.plane.height =  CGFloat(imageSize.height)
            case .aspectFill:
                self.plane.height = CGFloat(imageSize.height)
                guard let url = self.urlOfCurrentlyPlaying(in: self.avPlayer) else { fatalError() }
                let resolution = self.resolutionSizeForLocalVideo(url: url)
                let ratio = CGFloat(resolution!.width/resolution!.height)
                let width = imageSize.height * ratio
                self.plane.width = width
            }
            
            self.plane.width = self.plane.width * CGFloat(media.scale ?? 1)
            self.plane.height = self.plane.height * CGFloat(media.scale ?? 1)
            
            self.position.x = self.position.x + Float((media.position?[0] ?? 0))
            self.position.y = self.position.y + Float((media.position?[2] ?? 0))
            self.position.z = self.position.z + Float((media.position?[1] ?? 0))
        }
        
    }
    
    private func resolutionSizeForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    private func urlOfCurrentlyPlaying(in player: AVPlayer) -> URL? {
        return ((player.currentItem?.asset) as? AVURLAsset)?.url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
