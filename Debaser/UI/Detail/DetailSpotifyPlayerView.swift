//
//  DetailSpotifyPlayerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-12.
//

import SwiftUI

struct DetailSpotifyPlayerView: View {
    @Environment(\.spotifyService) var spotifyService
    
    let songTitle: String
    let artistName: String
    let albumName: String
    let artworkURL: String?

    @Binding var isStreaming: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Detail.Preview.Artist")
                .font(Font.Variant.tiny.font)
                .fontWeight(.semibold)
            
            HStack(spacing: 15) {
                DetailSpotifyPlayButtonView(isStreaming: $isStreaming, artworkURL: artworkURL)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(songTitle)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Text(artistName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                                
                Spacer()

                Image("SpotifyIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
            }
        }
    }
}

struct DetailSpotifyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        DetailSpotifyPlayerView(
            songTitle: "Song title",
            artistName: "Artist name",
            albumName: "Album name",
            artworkURL: "",
            isStreaming: .constant(false)
        )
    }
}
