//
//  DetailAppleMusicPlayerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-10.
//

import SwiftUI

struct DetailAppleMusicPlayerView: View {
    @Environment(\.appleMusicService) var appleMusicService

    let songTitle: String
    let artistName: String
    let artwork: String

    @Binding var isStreaming: Bool
    
    @State private var streamProgress: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Detail.Preview.Artist")
                .font(Font.Variant.tiny.font)
                .fontWeight(.semibold)
            
            HStack(spacing: 10) {
                Button(action: {
                    isStreaming.toggle()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 0)
                        .overlay(
                            Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 11, height: 11)
                                .offset(x: isStreaming ? 0 : 2)
                                .animation(nil, value: streamProgress > 0.0)
                        )
                        .overlay(
                            GeometryReader { geometry in
                                DetailStreamAnimatableProgress(
                                    width: geometry.size.width,
                                    height: geometry.size.height,
                                    streamProgress: streamProgress,
                                    lineWidth: 1.5,
                                    strokeColor: UIColor.red.cgColor
                                )
                            }
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
                    Text(songTitle)
                        .font(.subheadline)
                    Text(artistName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()

                Image("AppleMusicIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
            }
        }
    }
}

struct DetailAppleMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        DetailAppleMusicPlayerView(
            songTitle: "Song title",
            artistName: "Artist name",
            artwork: "",
            isStreaming: .constant(false)
        )
    }
}

