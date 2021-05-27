//
//  ListViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-24.
//

struct ListViewModel {
    
    /// Transform a list of events into carousel items
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list of carousel cards
    func getCardsForCarousel(events: [EventViewModel]) -> [Card] {
        var cards: [Card] = []
        
        for (index, event) in events.enumerated() {
            cards.append(
                Card(id: index, event: event)
            )
        }
        
        return cards
    }
    
    
    /// Get all available events
    ///
    /// - returns: A list of events
    func getEvents(from store: AppStore) -> [EventViewModel] {
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
    func getEventsInCurrentYear(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events)
    }
    
    /// Get events in near future (next year)
    ///
    /// - parameter events: List of events to filter from
    /// - returns: A list of events in near future
    func getEventsInNearFuture(_ events: [EventViewModel]) -> [EventViewModel] {
        return filterOutEventsRelatedToCurrentYear(events: events, isIncluded: false)
    }
    
    /// Get events of current date
    ///
    /// - returns: A list of events
    func getTodayEvents(from store: AppStore) -> [EventViewModel] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = filterOutCancelledEvents(events: events)
        }
        
        events = events.filter({ event -> Bool in
            if let date = dateFormatter.date(from: event.date) {
                return calendar.isDateInToday(date)
            }
            
            return true
        })
        
        return events
    }
    
    /// Get events of current week
    ///
    /// - returns: A list of events
    func getWeeklyEvents(from store: AppStore) -> [EventViewModel] {
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
    func filterOutCancelledEvents(events: [EventViewModel]) -> [EventViewModel] {
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
    func filterOutEventsRelatedToCurrentYear(events: [EventViewModel], isIncluded: Bool = true) -> [EventViewModel] {
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
    func getNextYear() -> String? {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        
        guard let nextYearDate = Calendar.current.date(byAdding: dateComponents, to: Date()) else {
            return nil
        }
        
        return "\(Calendar.current.component(.year, from: nextYearDate))"
    }

}
