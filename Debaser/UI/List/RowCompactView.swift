//
//  RowCompactView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI

struct RowCompactView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = RowViewViewModel()

    @State private var isShowingDetailView: Bool = false
    @Binding var isShowingTabBar: Bool

    private var title: String = ""
    private var date: String = ""
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        let rawDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter.string(from: rawDate!)
    }
    
    var event: EventViewModel
    var mediaHeight: CGFloat
    var willShowInfoBar = false
    
    init(event: EventViewModel, mediaHeight: CGFloat = 100, isShowingTabBar: Binding<Bool>) {
        self.event = event
        self.mediaHeight = mediaHeight
        self._isShowingTabBar = isShowingTabBar
        
        title = event.title
        date = event.date
    }
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                self.isShowingDetailView = true
                
                withAnimation {
                    self.isShowingTabBar = false
                }
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    RowCompactImageView(mediaHeight: mediaHeight)
                        .environmentObject(viewModel)
                        .onAppear {
                            if showImagesIfNeeded() {
                                viewModel.loadImage(with: event.image)
                            }
                        }

                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .padding(.top, 10)
                    
                    Text(formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)

                    Text(event.venue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
        }
    }
    
    func showImagesIfNeeded() -> Bool {
        return store.state.settings.showImages.value == true
    }
}

struct RowCompactImageView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var viewModel: RowViewViewModel
    @State private var opacity: Double = 0

    var mediaHeight: CGFloat?

    var body: some View {
        if showImagesIfNeeded() {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(height: mediaHeight)
                .frame(minWidth: 0, maxWidth: .infinity)
                .cornerRadius(15)
                .opacity(opacity)
                .onReceive(viewModel.$isLoaded) { isLoaded in
                    if isLoaded {
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                }
        } else {
            Rectangle()
                .fill(Color.listNoImageBackground)
                .frame(height: mediaHeight)
        }
    }
    
    func showImagesIfNeeded() -> Bool {
        return store.state.settings.showImages.value == true
    }
}

struct RowCompactView_Previews: PreviewProvider {
    static var previews: some View {
        let store: Store<AppState, AppAction> = Store(
            initialState: AppState(
                list: ListState(),
                settings: SettingsState(),
                onboarding: OnboardingState()
            ),
            reducer: appReducer
        )
        
        let event = Event(id: "1234",
                          name: "MR MS",
                          status: "Open",
                          description: "Lorem ipsum dolor",
                          ageLimit: "18 år",
                          image: "https://debaser.se/img/10982.jpg",
                          date: "2010-01-19",
                          room: "Bar Brooklyn",
                          venue: "Strand",
                          ticketUrl: nil)
        
        let model = EventViewModel(with: event)
        
        RowCompactView(event: model,
                       isShowingTabBar: .constant(false))
            .preferredColorScheme(.dark)
            .environmentObject(store)
    }
}
