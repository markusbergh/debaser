//
//  DetailAppleMusicPlayerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-10.
//

import SwiftUI

struct DetailAppleMusicPlayerView: View {
    @Environment(\.appleMusicService) var appleMusicService

    let artistName: String
    let albumTitle: String
    let artwork: String

    @Binding var isStreaming: Bool
    
    @State private var streamProgress: CGFloat = 0.0
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                isStreaming.toggle()
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 0)
                    .overlay(
                        Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 11, height: 11)
                            .offset(x: isStreaming ? 0 : 2)
                            .animation(nil)
                    )
                    .overlay(
                        DetailStreamProgress(
                            streamProgress: streamProgress,
                            strokeColor: UIColor.red.cgColor,
                            lineWidth: 1.5
                        )
                    )
                    .onReceive(appleMusicService.currentTimePublisher) { progress in
                        let currentTime = progress[0]
                        let totalTime = progress[1]
                        
                        streamProgress = CGFloat(currentTime / totalTime)
                        
                        if streamProgress >= 1.0 {
                            isStreaming = false
                            streamProgress = 0.0
                        }
                    }
            }
            
            VStack(alignment: .leading) {
                Text(artistName)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image("AppleMusicLockup")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DetailAppleMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        DetailAppleMusicPlayerView(
            artistName: "Song title",
            albumTitle: "Album title",
            artwork: "",
            isStreaming: .constant(false)
        )
    }
}

