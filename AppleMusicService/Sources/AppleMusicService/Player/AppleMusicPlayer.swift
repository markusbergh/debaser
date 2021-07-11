//
//  AppleMusicPlayer.swift
//  
//
//  Created by Markus Bergh on 2021-07-09.
//

import AVFoundation
import Combine
import Foundation
import MediaPlayer

class AppleMusicPlayer {
    
    private let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var queue: MPMusicPlayerStoreQueueDescriptor? {
        didSet {
            guard let queue = queue,
                  let storeIds = queue.storeIDs,
                  !storeIds.isEmpty else { return }
            
            musicPlayer.qu
            
            musicPlayer.setQueue(with: storeIds)
        }
    }
    private let durationDidChange = PassthroughSubject<[Double], Never>()
    private var audioPlayerItem: AVPlayerItem?
    private lazy var audioPlayer: AVPlayer = {
        let audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        
        return audioPlayer
    }()

}

// MARK: - Metadata

extension AppleMusicPlayer {
    
    private func observeCurrentTime() {
        guard let audioPlayerItem = audioPlayerItem else {
            return
        }

        audioPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { time in
            guard self.audioPlayer.currentItem?.status == .readyToPlay else {
                return
            }
            
            let currentTime = ceil(self.audioPlayer.currentTime().seconds)
            let totalTime = ceil(audioPlayerItem.duration.seconds)

            self.durationDidChange.send([currentTime, totalTime])
        }
    }
    
    func subscribeCurrentTimeDidChange() -> AnyPublisher<[Double], Never> {
        return durationDidChange.eraseToAnyPublisher()
    }
        
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
        
        // ... observe current time ...
        observeCurrentTime()
        
        // ... and play
        audioPlayer.play()
    }
    
    func stop() {
        audioPlayer.seek(to: .zero)
        audioPlayer.pause()
    }
}
