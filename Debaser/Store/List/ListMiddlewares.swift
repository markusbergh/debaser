//
//  Middleware.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

func listMiddleware(service: EventService = EventService.shared) -> Middleware<AppState, AppAction> {
    return { state, action in
        switch action {
        case .list(.getEventsRequest):
            guard let firstDate = ListMiddlewareDateHelper.today, let lastDate = ListMiddlewareDateHelper.dateInNearFuture else {
                return Empty().eraseToAnyPublisher()
            }
            
            return service.getPublisher(fromDate: firstDate, toDate: lastDate)
                .subscribe(on: RunLoop.main)
                .map { AppAction.list(.getEventsComplete(events: $0)) }
                .catch { (error: ServiceError) -> Just<AppAction> in
                    Just(AppAction.list(.getEventsError(error: error)))
                }
                .eraseToAnyPublisher()
            
        case .list(.searchEvent(let searchQuery)):
            if ListMiddlewareSearchHelper.events.isEmpty {
                ListMiddlewareSearchHelper.events = state.list.events
            }
            
            guard !searchQuery.isEmpty else {
                // Reset data with saved reference
                return CurrentValueSubject<AppAction, Never>(
                    AppAction.list(.getEventsComplete(events: ListMiddlewareSearchHelper.events))
                )
                .eraseToAnyPublisher()
            }
            
            return Just(searchQuery)
                .subscribe(on: RunLoop.main)
                .map { text in
                    let filteredEvents = ListMiddlewareSearchHelper.events.filter { event in
                        return event.title.lowercased().contains(text.lowercased())
                    }
                    
                    return AppAction.list(.getEventsComplete(events: filteredEvents))
                }
                .eraseToAnyPublisher()
        
        case .list(.getFavouritesRequest):
            guard let events = ListMiddlewareFavouritesHelper.getAll() else {
                return Just(AppAction.list(.getFavouritesError))
                    .eraseToAnyPublisher()
            }

            return Just(events)
                .subscribe(on: RunLoop.main)
                .map { events in
                    return AppAction.list(.getFavouritesComplete(events))
                }
                .eraseToAnyPublisher()
            
        case .list(.toggleFavourite(let event)):
            guard let events = ListMiddlewareFavouritesHelper.save(event) else {
                return Just(AppAction.list(.toggleFavouriteError))
                    .eraseToAnyPublisher()
            }
            
            return Just(events)
                .subscribe(on: RunLoop.main)
                .map { events in
                    return AppAction.list(.toggleFavouriteComplete(events))
                }
                .eraseToAnyPublisher()
            
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
}

// MARK: - Helpers

struct ListMiddlewareSearchHelper {
    static var events = [EventViewModel]()
}

struct ListMiddlewareDateHelper {
    private static var dateComponents = Calendar.current.dateComponents([.year], from: Date())
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter
    }()

    /// Today as text
    static var today: String? {
        return dateFormatter.string(from: Date())
    }
    
    /// First day of year as text
    static var firstDayOfYear: String? = {
        dateComponents.calendar = Calendar.current
        dateComponents.day = 1
        dateComponents.month = 1
        
        guard let date = dateComponents.date, dateComponents.isValidDate else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }()
    
    /// Last day of year as text
    static var lastDayOfYear: String? = {
        guard let startDateOfYear = Calendar.current.date(from: dateComponents) else {
            return nil
        }
        
        dateComponents.year = 1
        dateComponents.day = -1
        
        guard let lastDateOfYear = Calendar.current.date(byAdding: dateComponents, to: startDateOfYear) else {
            return nil
        }
        
        return dateFormatter.string(from: lastDateOfYear)
    }()
    
    /// A date in near future (1 year later)
    static var dateInNearFuture: String? = {
        guard let startDateOfYear = Calendar.current.date(from: dateComponents) else {
            return nil
        }
        
        dateComponents.year = 2
        dateComponents.day = -1
        
        guard let lastDateOfYear = Calendar.current.date(byAdding: dateComponents, to: startDateOfYear) else {
            return nil
        }
        
        return dateFormatter.string(from: lastDateOfYear)
    }()
}

struct ListMiddlewareFavouritesHelper {
    
    ///
    /// Get all favourite events
    ///
    /// - returns: A list of favourite events
    ///
    static func getAll() -> [EventViewModel]? {
        let userDefaults = UserDefaults.standard

        guard let data = userDefaults.object(forKey: "SavedEvents") as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        guard let storedList = try? decoder.decode([EventViewModel].self, from: data) else {
            return nil
        }
        
        return storedList
    }
    
    ///
    /// Saves an event as favourite
    ///
    /// - parameter event: Event to save
    /// - returns: A list of favourite events
    ///
    static func save(_ event: EventViewModel) -> [EventViewModel]? {
        let userDefaults = UserDefaults.standard
        
        guard let storedList = userDefaults.object(forKey: "SavedEvents") else {
            // No previous list available so create a new one
            let eventList = [event]
            
            let encoder = JSONEncoder()
            
            if let encodedList = try? encoder.encode(eventList) {
                userDefaults.setValue(encodedList, forKey: "SavedEvents")
            }
            
            return [event]
        }
        
        // Try and update available list
        return update(for: event, with: storedList)
    }
    
    ///
    /// Updates or saves an event in favourite list
    ///
    /// - parameters:
    ///   - event: Event to save
    ///   - data: Data to update
    /// - returns: A list of favourite events
    ///
    static func update(for event: EventViewModel, with data: Any) -> [EventViewModel]? {
        guard let data = data as? Data else {
            return nil
        }
        
        let userDefaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        if var storedList = try? decoder.decode([EventViewModel].self, from: data) {
            for (index, storedEvent) in storedList.enumerated() {
                // Match found, so remove it
                if storedEvent.id == event.id {
                    storedList.remove(at: index)
                    
                    if let updatedList = try? encoder.encode(storedList) {
                        userDefaults.setValue(updatedList, forKey: "SavedEvents")
                    }
                    
                    return storedList
                }
            }

            // Otherwise just add event to list
            storedList.append(event)

            if let updatedList = try? encoder.encode(storedList) {
                userDefaults.setValue(updatedList, forKey: "SavedEvents")
            }

            return storedList
        }
        
        return nil
    }
}
