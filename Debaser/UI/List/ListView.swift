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
                    let eventsForCurrentYear = getEventsCurrentYear(allEvents)
                    let eventsInNearFuture = getEventsInNearFuture(allEvents)
                    
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(0..<eventsForCurrentYear.count, id:\.self) { idx in
                            let event = eventsForCurrentYear[idx]
                            
                            ListRowView(
                                event: event,
                                mediaHeight: 150
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .id(event.id)
                        }
                        
                        // Show also the events in the near future...
                        if !eventsInNearFuture.isEmpty {
                            ForEach(0..<eventsInNearFuture.count, id:\.self) { idx in
                                if idx == 0 {
                                    SeparatorView()
                                        .frame(width: (UIScreen.main.bounds.width - listPadding * 2))
                                    
                                    // Hacky hack to display the previous item with full width
                                    Color.clear
                                    
                                    if let nextYear = getNextYear() {
                                        // For now we assume it is next year, but should rather be available in data list
                                        Text(nextYear)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Capsule().fill(Color.listRowBackground))
                                        
                                        // Hacky hack to display the previous item with full width
                                        Color.clear
                                    }
                                }
                                
                                let event = eventsInNearFuture[idx]
                                
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
    
    private func getCardsForCarousel(events: [EventViewModel]) -> [Card] {
        var cards: [Card] = []
        
        for (index, event) in events.enumerated() {
            cards.append(
                Card(id: index, event: event)
            )
        }
        
        return cards
    }
    
    private func getEvents() -> [EventViewModel] {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterHideCancelledEvents(events: events)
        }
        
        return events
    }
    
    private func getEventsCurrentYear(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events)
    }
    
    private func getEventsInNearFuture(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events, isIncluded: false)
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
    
    private func getNextYear() -> String? {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        
        guard let nextYearDate = Calendar.current.date(byAdding: dateComponents, to: Date()) else {
            return nil
        }
        
        return "\(Calendar.current.component(.year, from: nextYearDate))"
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
