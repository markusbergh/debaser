//
//  AppleMusicService.swift
//  AppleMusicService
//
//  Created by Markus Bergh on 2021-07-06.
//

import Combine
import Foundation

public final class AppleMusicService {
    
    // MARK: Static
    
    public static let shared = AppleMusicService()
    
    // MARK: Private
    
    private let apiClient: AppleMusicAPIClient
    private let musicPlayer: AppleMusicPlayer
    private var cancellable: AnyCancellable?
    
    init(apiClient: AppleMusicAPIClient = AppleMusicAPIClient(), musicPlayer: AppleMusicPlayer = AppleMusicPlayer()) {
        self.apiClient = apiClient
        self.musicPlayer = musicPlayer
    }
    
}

// MARK: - Service

extension AppleMusicService {
    
    public func play(with storeIds: [String]) {
        // Set queue...
        musicPlayer.setQueue(with: storeIds)
        
        // ... then play
        musicPlayer.play()
    }
    
    public func canPlaySongPreview(for searchTerm: String, completion: @escaping (SongAttributes?) -> Void) {
        cancellable = apiClient.songAttributes(for: searchTerm)
            .sink(receiveCompletion: { response in
                switch response {
                case .failure:
                    completion(nil)
                case .finished:
                    break
                }
            }, receiveValue: { songAttributes in
                // We can actually only preview a song, if there is a preview...
                guard (songAttributes?.previews.first) != nil else { return }
                
                // ... but return all attributes for more data
                completion(songAttributes)
            })
    }
    
    public func playSongPreview(with preview: SongPreview) {
        self.musicPlayer.playPreview(with: preview.url)
    }
    
    public func stop() {
        self.musicPlayer.stop()
    }
    
    public var currentTimePublisher: AnyPublisher<[Double], Never> {
        return musicPlayer.subscribeCurrentTimeDidChange()
    }
    
}
