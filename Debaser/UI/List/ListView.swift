//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var carouselState: CarouselState
        
    @State private var isShowingErrorAlert = false
    @State private var midY: CGFloat = .zero
    
    let headline: String
    let label: LocalizedStringKey
        
    private let viewModel = ListViewModel()

    private var listLabel: LocalizedStringKey {
        return store.state.list.currentSearch.isEmpty ? "List.All" : "List.Search.Result"
    }
    
    private var emptyListLabel: LocalizedStringKey {
        return "List.Empty"
    }
    
    private var emptyCarouselText: LocalizedStringKey {
        var text = store.state.list.isFetching.value ? "List.Loading" : emptyListLabel
        
        if store.state.list.fetchError != nil {
            text = "Det gick inte att hämta event"
        }
        
        return text
    }
    
    private var gridLayout: [GridItem] {
        return Array(
            repeating: .init(
                .flexible(
                    minimum: 0,
                    maximum: .infinity
                ),
                spacing: 20,
                alignment: .leading
            ),
            count: 2
        )
    }

    private let listPadding: CGFloat = 20

    private var listWidth: CGFloat {
        return UIScreen.main.bounds.width - (listPadding * 2)
    }

    private var listBottomPadding: CGFloat {
        return TabBarStyle.paddingBottom.rawValue + TabBarStyle.height.rawValue + listPadding + 15
    }

    private var darkMode: Binding<Bool> {
        let darkMode = Binding<Bool>(
            get: {
                return store.state.settings.darkMode.value
            },
            set: {
                store.dispatch(action: .settings(.setDarkMode($0)))
            }
        )
        
        return darkMode
    }
    
    private var currentSearch: Binding<String> {
        let currentSearch = Binding(
            get: {
                return store.state.list.currentSearch
            },
            set: {
                store.dispatch(action: .list(.searchEvent(query: $0)))
            }
        )
        
        return currentSearch
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ListHeaderView(
                    headline: headline,
                    label: label,
                    isDarkMode: darkMode,
                    currentSearch: currentSearch
                )
                .padding(.horizontal, listPadding)
                
                if store.state.list.currentSearch.isEmpty {
                    let events = viewModel.getTodayEvents(from: store)
                    
                    if !events.isEmpty {
                        let cards = viewModel.getCardsForCarousel(events: events)
                                            
                        SnapCarousel(
                            state: carouselState,
                            spacing: 16,
                            widthOfHiddenCards: 16,
                            cardHeight: 185,
                            items: cards
                        )
                    } else if events.isEmpty {
                        VStack {
                            Text(emptyCarouselText)
                                .font(Font.Variant.small(weight: .semibold).font)
                        }
                        .frame(height: 170)
                        .padding(listPadding)
                    }
                    
                    Divider()
                        .background(Color.listDivider)
                        .padding(.vertical, 10)
                        .padding(.horizontal, listPadding)
                }
                
                let allEvents = viewModel.getEvents(from: store)
                
                VStack {
                    HStack {
                        if allEvents.isEmpty, !store.state.list.currentSearch.isEmpty {
                            Text("List.Search.Result.Empty")
                                .font(Font.Variant.small(weight: .medium).font)
                        } else {
                            Text(listLabel)
                                .font(Font.Variant.small(weight: .regular).font)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .background(Capsule().fill(Color.listRowBackground))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    SeparatorView()
                        .frame(height: 15)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, listPadding)
                .padding(.top, listPadding)
                .padding(.bottom, 10)

                if !allEvents.isEmpty {
                    let eventsForCurrentYear = viewModel.getEventsInCurrentYear(allEvents)
                    let eventsInNearFuture = viewModel.getEventsInNearFuture(allEvents)
                    
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(0..<eventsForCurrentYear.count, id:\.self) { index in
                            let event = eventsForCurrentYear[index]
                            let total = eventsForCurrentYear.count
                            
                            ListRowView(
                                event: event,
                                mediaHeight: 150
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .id(event.id)
                            
                            // Fill out list if needed, to push down section separator
                            if index == total - 1, index % 2 == 0 {
                                Color.clear
                            }
                        }
                        
                        // Show also the events in the near future...
                        if !eventsInNearFuture.isEmpty {
                            ForEach(0..<eventsInNearFuture.count, id:\.self) { index in
                                if index == 0, store.state.list.currentSearch.isEmpty {
                                    ListViewNextSection(
                                        listWidth: listWidth,
                                        nextYear: viewModel.getNextYear()
                                    )
                                }
                                
                                let event = eventsInNearFuture[index]
                                
                                ListRowView(
                                    event: event,
                                    mediaHeight: 150
                                )
                                .frame(maxHeight: .infinity, alignment: .top)
                                .id(event.id)
                            }
                        }
                    }
                    .padding(.bottom, listBottomPadding)
                    .padding(.horizontal, listPadding)
                }
            }
        }
        .padding(.vertical, listPadding)
        .background(
            ListViewTopRectangle(),
            alignment: .top
        )
        .background(Color.listBackground)
        .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: $isShowingErrorAlert) {
            Alert(title: Text("List.Error.Title"),
                  message: Text("List.Error.Message"),
                  dismissButton: .default(Text("OK")))
        }
        .onChange(of: store.state.list.fetchError, perform: { error in
            if let _ = error {
                isShowingErrorAlert = true
            }
        })
    }
}

// MARK: - Next section

struct ListViewNextSection: View {
    var listWidth: CGFloat
    var nextYear: String?
    
    var body: some View {
        SeparatorView()
            .frame(width: listWidth)
        
        // Hacky hack to display the previous item with full width
        Color.clear
        
        // For now we assume it is next year, but should rather be available in data list
        if let nextYear = nextYear {
            Text(nextYear)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Capsule().fill(Color.listRowBackground))
            
            // Hacky hack to display the previous item with full width
            Color.clear
        }
    }
}

// MARK: - Background gradient

struct ListViewTopRectangle: View {
    private let colorStart: Color = .listTopGradientStart
    private let colorEnd: Color = .listTopGradientEnd
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        colors: [colorStart, colorEnd]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .edgesIgnoringSafeArea(.top)
            .frame(height: 250)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        let empty = MockStore.store
        
        let event = MockEventViewModel.event
        let store = MockStore.store(with: [event])
        
        ListView(
            headline: "Stockholm",
            label: "Dagens konserter"
        )
        .environmentObject(store)
    }
}
