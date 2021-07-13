//
//  DetailView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-04.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// Services
    @Environment(\.spotifyService) var spotifyService

    /// Store
    @EnvironmentObject var store: AppStore
        
    /// Handling image loading
    @StateObject private var imageViewModel = ImageViewModel()
    
    /// If there is an audio stream for current artist
    @State private var canPreviewArtist = false
    
    /// Sets the audio streaming state
    @State private var isStreaming = false
    
    /// Determines if alert should be shown or not when event is overdue
    @State private var isShowingAlertDateOverdue = false
    
    /// Return shadow opacity depending on current color scheme
    private var shadowOpacity: Double {
        return colorScheme == .light ? 0.25 : 0.1
    }
    
    /// Returns top tracks for current artist, if any
    private var artistTopTrack: SpotifyTrack? {
        return store.state.spotify.topTracks?.first
    }
    
    /// Current event
    let event: EventViewModel
    
    /// Flag if view can be navigated back, will be false for a modal
    let canNavigateBack: Bool

    init(event: EventViewModel, canNavigateBack: Bool = true) {
        self.event = event
        self.canNavigateBack = canNavigateBack
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        if store.state.settings.showImages.value {
                            DetailTopImageView()
                                .environmentObject(imageViewModel)
                                .onAppear {
                                    imageViewModel.load(with: event.image)
                                }
                        }
                        
                        if canNavigateBack {
                            HStack {
                                DetailBackButtonView(isStreaming: $isStreaming)
                                
                                Spacer()
                            }
                            .padding(.horizontal, Style.padding.value)
                            .padding(.top, (Style.padding.value * 2))
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Group {
                        if canPreviewArtist, let track = artistTopTrack {                            
                            DetailSpotifyPlayerView(
                                songTitle: track.name,
                                artistName: track.artists.first?.name ?? "Unknown artist",
                                albumName: track.album.name,
                                artworkURL: track.album.images.first?.url,
                                isStreaming: $isStreaming
                            )
                            .padding(Style.padding.value)
                            .background(Color.detailContentBackground)
                            .cornerRadius(Style.cornerRadius.value)
                            .shadow(color: .black.opacity(shadowOpacity), radius: 20, x: 0, y: -5)
                            .padding([.leading, .top, .trailing], Style.padding.value)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        // Main content
                        DetailMainContentView(event: event)
                            .animation(.easeInOut)
                    }
                    .offset(y: Style.offset.value)
                }
            }
            .background(Color.detailBackground)
            .ignoresSafeArea()
            .frame(height: geometry.size.height)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onChange(of: store.state.spotify.hasTracksForCurrentArtist) { hasTracks in
                canPreviewArtist = hasTracks
            }
            .onChange(of: isStreaming) { shouldStream in
                if shouldStream {                    
                    do {
                        try spotifyService.playTrackForArtist()
                    } catch {
                        // Error is not handled
                    }
                } else {
                    spotifyService.playPauseStream()
                }
            }
            .onAppear {
                // Search for artist if eligible to do so
                if store.state.spotify.isLoggedIn == true {
                    store.dispatch(action: .spotify(.requestSearchArtist(event.title)))
                }
                
                // Always hide tab bar
                if store.state.list.isShowingTabBar == true {
                    store.dispatch(action: .list(.hideTabBar))
                }
                
                // Has this event already happened?
                DispatchQueue.main.async {
                    if event.isDateExpired {
                        isShowingAlertDateOverdue = true
                    }
                }
            }
            .onDisappear {
                // Always show tab bar
                store.dispatch(action: .list(.showTabBar))
                
                if isStreaming {
                    spotifyService.playPauseStream()
                }
            }
            .alert(isPresented: $isShowingAlertDateOverdue) {
                Alert(
                    title: Text("Detail.Event.Overdue.Title"),
                    message: Text("Detail.Event.Overdue.Message"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Main content

struct DetailMainContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isFavourite = false
    @State private var titleHeight: CGFloat = 0.0
    
    // TODO: Consider look into this issue with setting width
    @State private var titleWidth: CGFloat = UIScreen.main.bounds.width - (Style.padding.value * 4)
    
    private var shadowOpacity: Double {
        return colorScheme == .light ? 0.25 : 0.1
    }

    var event: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                DetailTopMetaView(event: event)

                Spacer()
                
                DetailFavouriteButtonView(event: event)
            }
            .padding(.bottom, 35)
            
            Text(event.title)
                .font(Font.Family.title.of(size: 49))
                .padding(.bottom, 10)

            DetailMetaContainerView(
                ageLimit: event.ageLimit,
                admission: event.admission,
                open: event.openHours
            )

            SeparatorView()
                .frame(height: 10)
            
            if !event.isFreeAdmission {
                DetailBuyTicketButtonView(event: event)
            }
            
            DetailDescriptionView(
                subHeader: event.subHeader,
                description: event.description
            )
            .padding(.top, Style.padding.value)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Style.padding.value)
        .background(Color.detailContentBackground)
        .cornerRadius(Style.cornerRadius.value)
        .shadow(color: .black.opacity(shadowOpacity), radius: 20, x: 0, y: -5)
        .padding([.leading, .top, .trailing], Style.padding.value)
        .padding(.bottom, Style.offset.value + Style.padding.value)
    }
}

// MARK: - Metadata

struct DetailMetaContainerView: View {
    var ageLimit: String
    var admission: String
    var open: String
    
    var body: some View {
        HStack {
            DetailMetaView(
                type: .age,
                label: ageLimit,
                backgroundColor: .detailViewMetaPrimary
            )
            
            DetailMetaView(
                type: .admission,
                label: admission,
                backgroundColor: .detailViewMetaSecondary
            )
            
            DetailMetaView(
                type: .open,
                label: open,
                backgroundColor: .detailViewMetaTertiary
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 15)
    }
}

// MARK: - Description

struct DetailDescriptionView: View {
    var subHeader: String?
    var description: String
    
    var body: some View {
        if let subHeader = subHeader, !subHeader.isEmpty {
            Text(subHeader)
                .font(Font.Variant.body(weight: .semibold).font)
                .lineSpacing(2)
        }

        Text(description)
            .font(Font.Variant.body(weight: .regular).font)
            .lineSpacing(2)
    }
}

// MARK: - Back button

struct DetailBackButtonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode
    @Binding var isStreaming: Bool

    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            isStreaming = false
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .resizable()
                .foregroundColor(Color.detailBackButtonTint)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .frame(width: 40, height: 40)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Style

private enum Style {
    case padding
    case cornerRadius
    case offset
    
    var value: CGFloat {
        switch self {
        case .padding:
            return 25
        case .cornerRadius:
            return 25
        case .offset:
            return -50
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let artist = SpotifyArtist(name: "Artist name")
        let album = SpotifyAlbum(name: "This is an album name", releaseDate: "2018-09-28", images: [], uri: "")
        let track = SpotifyTrack(name: "Test", uri: "", album: album, artists: [artist])

        let store = MockStore.store(withTopTracks: [track])
        let event = EventViewModel.mock
        
        DetailView(event: event)
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: "en"))
            .environmentObject(store)
    }
}
