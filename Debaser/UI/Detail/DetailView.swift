//
//  DetailView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-04.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = DetailViewViewModel()
    
    var event: EventViewModel
    
    @State private var canPreviewArtist = false
    @State private var isStreaming = false

    init(event: EventViewModel) {
        self.event = event
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        DetailTopImageView()
                            .environmentObject(viewModel)
                        
                        HStack {
                            DetailBackButtonView(isStreaming: $isStreaming)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity)
                        
                        if canPreviewArtist {
                            DetailSpotifyPlayerView(isStreaming: $isStreaming)
                        }
                    }
                    
                    // Main content
                    DetailMainContentView(event: event)
                }
            }
            .background(Color.detailBackground)
            .ignoresSafeArea()
            .frame(height: geometry.size.height)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onChange(of: store.state.spotify.hasTracksForCurrentArtist) { hasTracks in
                if hasTracks {
                    DispatchQueue.main.async {
                        withAnimation {
                            canPreviewArtist = true
                        }
                    }
                }
            }
            .onChange(of: isStreaming) {
                $0 ? SpotifyService.shared.playTrackForArtist() : SpotifyService.shared.playPauseStream()
            }
            .onAppear {
                // Load image
                viewModel.loadImage(with: event.image)
                
                // Search for artist if eligible to do so
                if store.state.spotify.isLoggedIn == true {
                    store.dispatch(withAction: .spotify(.requestSearchArtist(event.title)))
                }
            }
            .onDisappear {
                store.dispatch(withAction: .list(.showTabBar))
                
                if isStreaming {
                    SpotifyService.shared.playPauseStream()
                }
            }
        }
    }
}

// MARK: Spotify player

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
                        .fontWeight(.heavy)
                        .textCase(.uppercase)
                        .font(.system(size: 11))
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

// MARK: Top image

struct DetailTopImageView: View {
    @EnvironmentObject var viewModel: DetailViewViewModel
    
    var body: some View {
        GeometryReader { geometry -> DetailImageView in
            var width =  geometry.size.width
            var height = geometry.size.height + geometry.frame(in: .global).minY
            var offsetY = -geometry.frame(in: .global).minY
            
            if geometry.frame(in: .global).minY <= 0 {
                width = geometry.size.width
                height = geometry.size.height
                offsetY = -geometry.frame(in: .global).minY / 3
            }
            
            return DetailImageView(
                image: viewModel.image,
                width: width,
                height: height,
                offsetY: offsetY
            )
        }
        .frame(height: 300)
    }
}

// MARK: Back button

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
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                )
        }
    }
}

// MARK: Main content

struct DetailMainContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isFavourite = false
    private var cancelledLabel: String {
        return NSLocalizedString("List.Event.Cancelled", comment: "A cancelled event")
    }
    
    private var postponedLabel: String {
        return NSLocalizedString("List.Event.Postponed", comment: "A postponed event")
    }

    var event: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if event.isCancelled {
                    DetailMetaView(
                        label: cancelledLabel,
                        labelSize: 17,
                        labelColor: .white,
                        backgroundColor: .red
                    )
                } else if event.isPostponed {
                    DetailMetaView(
                        label: postponedLabel,
                        labelSize: 17,
                        labelColor: .white,
                        backgroundColor: .red
                    )
                } else {
                    Text(event.getShortDate())
                        .font(.system(size: 15))
                        .frame(minHeight: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .strokeBorder(lineWidth: 1.0)
                        )
                }
                
                DetailMetaView(
                    label: event.venue,
                    labelSize: 15,
                    labelColor: colorScheme == .dark ? .black : .white,
                    backgroundColor: .primary
                )

                Spacer()
                
                DetailFavouriteButtonView(event: event)
            }
            .padding(.bottom, 35)

            TitleView(title: event.title, innnerPadding: 25, outerPadding: 25)
                .fixedSize(horizontal: false, vertical: false)
                .padding(.bottom, 10)
                
            DetailMetaContainerView(
                ageLimit: event.ageLimit,
                admission: event.admission,
                open: event.open
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
            .padding(.top, 25)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(25)
        .background(Color.detailContentBackground)
        .cornerRadius(25)
        .shadow(
            color: Color.black.opacity(colorScheme == .light ? 0.25 : 0.1),
            radius: 20,
            x: 0,
            y: -5
        )
        .padding(25)
    }
}

// MARK: Meta container view

struct DetailMetaContainerView: View {
    var ageLimit: String
    var admission: String
    var open: String
    
    var body: some View {
        var formattedAdmission = admission
        
        if admission.contains("Fri") {
            formattedAdmission = NSLocalizedString("Detail.Meta.Admission.Free", comment: "Admission information")
        }
        
        return HStack {
            DetailMetaView(
                image: "person",
                label: ageLimit,
                backgroundColor: .detailViewMetaPrimary
            )
            DetailMetaView(
                image: "banknote",
                label: formattedAdmission,
                backgroundColor: .detailViewMetaSecondary
            )
            DetailMetaView(
                image: "clock",
                label: open,
                backgroundColor: .detailViewMetaTertiary
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 15)
    }
}

// MARK: Description view

struct DetailDescriptionView: View {
    var subHeader: String?
    var description: String
    
    var body: some View {
        if let subHeader = subHeader, !subHeader.isEmpty {
            Text(subHeader)
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .lineSpacing(2)
        }

        Text(description)
            .font(.system(size: 19))
            .lineSpacing(2)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event
        
        /*
        ForEach(ColorScheme.allCases, id:\.self) {
            DetailView(event: event)
                .preferredColorScheme(.dark)
                .environmentObject(store)
                .preferredColorScheme($0)
        }
        */
        
        DetailView(event: event)
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: "en"))
            .environmentObject(store)
    }
}
