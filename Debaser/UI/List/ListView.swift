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
    @State private var listPadding: CGFloat = 20
    @State private var midY: CGFloat = .zero
    
    let headline: String
    let label: LocalizedStringKey

    private var listLabel: LocalizedStringKey {
        return store.state.list.currentSearch.isEmpty ? "List.All" : "List.Search.Result"
    }
    
    private var emptyListLabel: LocalizedStringKey {
        return "List.Empty"
    }
    
    private var gridLayout: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 0, maximum: .infinity), spacing: 20, alignment: .leading), count: 2)
    }

    private var listBottomPadding: CGFloat {
        return TabBarStyle.paddingBottom.rawValue + TabBarStyle.height.rawValue + listPadding + 15
    }
    
    private var listWidth: CGFloat {
        return UIScreen.main.bounds.width - (listPadding * 2)
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
                    let events = getTodayEvents()
                    
                    if !events.isEmpty {
                        let cards = getCardsForCarousel(events: events)
                                            
                        SnapCarousel(
                            UIState: carouselState,
                            spacing: 16,
                            widthOfHiddenCards: 16,
                            cardHeight: 185,
                            items: cards
                        )
                    } else if events.isEmpty {
                        VStack {
                            Text(store.state.list.isFetching.value ? "List.Loading" : emptyListLabel)
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
                
                let allEvents = getEvents()
                
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
                    let eventsForCurrentYear = getEventsInCurrentYear(allEvents)
                    let eventsInNearFuture = getEventsInNearFuture(allEvents)
                    
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
                                    SeparatorView()
                                        .frame(width: listWidth)
                                    
                                    // Hacky hack to display the previous item with full width
                                    Color.clear
                                    
                                    // For now we assume it is next year, but should rather be available in data list
                                    if let nextYear = getNextYear() {
                                        Text(nextYear)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Capsule().fill(Color.listRowBackground))
                                        
                                        // Hacky hack to display the previous item with full width
                                        Color.clear
                                    }
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

// MARK: - Helpers

// Carousel

extension ListView {
    
    /// Transform a list of events into carousel items
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list of carousel cards
    private func getCardsForCarousel(events: [EventViewModel]) -> [Card] {
        var cards: [Card] = []
        
        for (index, event) in events.enumerated() {
            cards.append(
                Card(id: index, event: event)
            )
        }
        
        return cards
    }
    
}

// Events

extension ListView {
    
    /// Get all available events
    ///
    /// - returns: A list of events
    private func getEvents() -> [EventViewModel] {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterOutCancelledEvents(events: events)
        }
        
        return events
    }
    
    /// Get available events for current year
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list of events in current year
    private func getEventsInCurrentYear(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events)
    }
    
    /// Get events in near future (next year)
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list of events in near future
    private func getEventsInNearFuture(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events, isIncluded: false)
    }
    
    /// Get events of current date
    ///
    /// - returns: A list of events
    private func getTodayEvents() -> [EventViewModel] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterOutCancelledEvents(events: events)
        }

        events = events.filter({ event -> Bool in
            if let date = dateFormatter.date(from: event.date) {
                return calendar.isDateInToday(date) || calendar.isDateInTomorrow(date)
            }
            
            return true
        })
        
        return events
    }
    
    /// Get events of current week
    ///
    /// - returns: A list of events
    private func getWeeklyEvents() -> [EventViewModel] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterOutCancelledEvents(events: events)
        }
        
        events = events.filter({ event -> Bool in
            if let date = dateFormatter.date(from: event.date) {
                return calendar.isDateInThisWeek(date)
            }
            
            return true
        })
        
        return events
    }
    
    /// Filter out cancelled events
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list without cancelled events
    private func filterOutCancelledEvents(events: [EventViewModel]) -> [EventViewModel] {
        return events.filter({ event -> Bool in
            guard let slug = event.slug else {
                return true
            }
            
            return !slug.contains("cancelled")
        })
    }
    
    /// Filter out events related to current year
    ///
    /// - parameters:
    ///     - events: List of events to filter from
    ///     - isIncluded: If the event of current year should be included
    /// - returns: A list without cancelled events
    private func filterOutEventsRelatedToCurrentYear(events: [EventViewModel], isIncluded: Bool = true) -> [EventViewModel] {
        let currentYear = Calendar.current.component(.year, from: Date())

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return events.filter({ event -> Bool in
            if let date = dateFormatter.date(from: event.date) {
                let eventYear = Calendar.current.component(.year, from: date)
                
                if eventYear == currentYear {
                    return isIncluded
                }
            }
            
            return !isIncluded
        })
    }
    
    /// Get next year as text
    ///
    /// - returns: Next year in string format
    private func getNextYear() -> String? {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        
        guard let nextYearDate = Calendar.current.date(byAdding: dateComponents, to: Date()) else {
            return nil
        }
        
        return "\(Calendar.current.component(.year, from: nextYearDate))"
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
