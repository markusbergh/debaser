//
//  DetailSpotifyPlayerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-08.
//

import SwiftUI

struct DetailSpotifyPlayerView: View {
    @Binding var isStreaming: Bool
    
    @State private var streamProgress: CGFloat = 0.0
    private let streamPositionDidUpdate = NotificationCenter.default.publisher(for: NSNotification.Name("spotifyStreamDidChangePosition"))

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ZStack {
                    Button(action: {
                        isStreaming.toggle()
                        streamProgress = 0.0
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                            .overlay(
                                Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .foregroundColor(.green)
                                    .frame(width: 22, height: 22)
                                    .offset(x: isStreaming ? 0 : 2)
                                    .animation(nil)
                            )
                            .overlay(
                                DetailViewStreamProgress(streamProgress: streamProgress)
                                    .onReceive(streamPositionDidUpdate, perform: { notification in
                                        guard let streamPositionObject = notification.object as? NSDictionary,
                                              let currentStreamPosition = streamPositionObject["current"] as? CGFloat else {
                                            return
                                        }
                                        
                                        // Update stream progress state
                                        streamProgress = currentStreamPosition / 100.0
                                    })
                            )
                    }
                    
                }
                .scaleEffect(isStreaming ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.35))
                
                HStack {
                    Text("Powered by")
                        .textCase(.uppercase)
                        .font(FontVariant.mini(weight: .heavy).font)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)

                    Image("SpotifyLogotype")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)

                }
                .frame(maxWidth: .infinity)
            }
        }
        .transition(.opacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
