//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var carouselState: UIStateModel
        
    @State private var isShowingErrorAlert = false
    @State private var isShowingActivityIndicator = false
    @State private var listPadding: CGFloat = 20
    @State private var midY: CGFloat = .zero
    
    var headline: String
    var label: LocalizedStringKey

    private var listLabel: LocalizedStringKey {
        return store.state.list.currentSearch.isEmpty ? "List.All" : "List.Search.Result"
    }
    
    private var gridLayout: [GridItem] {
        return Array(repeating: .init(.flexible(), spacing: 20), count: 2)
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
                store.dispatch(withAction: .settings(.setDarkMode($0)))
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
                store.dispatch(withAction: .list(.searchEvent(query: $0)))
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
                    Spacer().frame(height: 10)
                    
                    let events = getTodayEvents()
                    let cards = getCardsForCarousel(events: events)
                                        
                    SnapCarousel(
                        UIState: carouselState,
                        spacing: 16,
                        widthOfHiddenCards: 16,
                        cardHeight: 185,
                        items: cards
                    )
                    
                    Divider()
                        .background(Color.listDivider)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                }
                
                let events = getEvents()
                
                VStack {
                    HStack(spacing: 0) {
                        if events == nil, !store.state.list.currentSearch.isEmpty {
                            Text("List.Search.Result.Empty")
                                .font(.system(size: 17))
                                .fontWeight(.medium)
                        } else {
                            Text(listLabel)
                                .font(.system(size: 17))
                        }
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, listPadding)

                if let events = events {
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        
                        ForEach(0..<events.count, id:\.self) { idx in
                            let event = events[idx]
                            
                            RowCompactView(
                                event: event,
                                mediaHeight: 150
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .id(event.id)
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
        .onReceive(store.state.list.isFetching, perform: { isFetching in
            isShowingActivityIndicator = isFetching
        })
        .onChange(of: store.state.list.fetchError, perform: { error in
            if let _ = error {
                isShowingErrorAlert = true
            }
        })
        .overlay(
            ListProgressIndicatorView(isShowingActivityIndicator: isShowingActivityIndicator)
        )
    }
    
    private func getCardsForCarousel(events: [EventViewModel]) -> [Card] {
        var cards: [Card] = []
        
        for (index, event) in events.enumerated() {
            cards.append(
                Card(id: index, event: event)
            )
        }
        
        return cards
    }
    
    private func getEvents() -> [EventViewModel]? {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterHideCancelledEvents(events: events)
        }

        return events.isEmpty ? nil : events
    }
    
    private func getTodayEvents() -> [EventViewModel] {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterHideCancelledEvents(events: events)
        }

        events = events.filter({ event -> Bool in
            let calendar = Calendar.current
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = dateFormatter.date(from: event.date) {
                return calendar.isDateInToday(date) || calendar.isDateInTomorrow(date)
            }
            
            return true
        })
        
        return events
    }
    
    private func getWeekEvents() -> [EventViewModel] {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterHideCancelledEvents(events: events)
        }
        
        events = events.filter({ event -> Bool in
            let calendar = Calendar.current
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = dateFormatter.date(from: event.date) {
                return calendar.isDateInThisWeek(date)
            }
            
            return true
        })
        
        return events
    }
    
    private func filterHideCancelledEvents(events: [EventViewModel]) -> [EventViewModel] {
        return events.filter({ event -> Bool in
            guard let slug = event.slug else {
                return true
            }
            
            return !slug.contains("cancelled")
        })
    }
}

struct ListProgressIndicatorView: View {
    let isShowingActivityIndicator: Bool
    
    var body: some View {
        if isShowingActivityIndicator {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .progressIndicator))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .ignoresSafeArea()
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}

struct ListViewTopRectangle: View {
    let colorStart = Color.listTopGradientStart
    let colorEnd = Color.listTopGradientEnd
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient:
                        Gradient(
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
        let store = MockStore.store
        
        ListView(
            headline: "Stockholm",
            label: "Dagens konserter"
        )
        .environmentObject(store)
    }
}
