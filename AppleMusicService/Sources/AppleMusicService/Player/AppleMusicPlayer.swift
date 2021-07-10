//
//  AppleMusicPlayer.swift
//  
//
//  Created by Markus Bergh on 2021-07-09.
//

import AVFoundation
import Foundation
import MediaPlayer

class AppleMusicPlayer {
    
    private let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var queue: MPMusicPlayerStoreQueueDescriptor? {
        didSet {
            guard let queue = queue,
                  let storeIds = queue.storeIDs,
                  !storeIds.isEmpty else { return }
            
            musicPlayer.setQueue(with: storeIds)
        }
    }
    
    private var audioPlayerItem: AVPlayerItem?
    private lazy var audioPlayer: AVPlayer = {
        let audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        
        return audioPlayer
    }()

}

// MARK: - Player

extension AppleMusicPlayer {
    
    func setQueue(with storeIds: [String]) {
        queue = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIds)
    }
    
    func play() {
        musicPlayer.prepareToPlay { error in
            guard error == nil else {
                print(error)
                return
            }
            
            self.musicPlayer.play()
        }
    }
    
    func playPreview(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Set item...
        audioPlayerItem = AVPlayerItem(url: url)
        
        // ... and play
        audioPlayer.play()
    }
    
    func stop() {
        audioPlayer.seek(to: .zero)
        audioPlayer.pause()
    }
}
