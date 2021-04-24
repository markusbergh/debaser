//
//  Middleware.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

func listMiddleware(service: EventService) -> Middleware<AppState, AppAction> {
    return { state, action in
        switch action {
        case .list(.getEventsRequest):
            guard let firstDate = ListMiddlewareHelper.firstDayOfYear, let lastDate = ListMiddlewareHelper.lastDayOfYear else {
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
            if ListMiddlewareHelper.events.isEmpty {
                ListMiddlewareHelper.events = state.list.events
            }
            
            guard !searchQuery.isEmpty else {
                // Reset data with saved reference
                return CurrentValueSubject<AppAction, Never>(
                    AppAction.list(.getEventsComplete(events: ListMiddlewareHelper.events))
                )
                .eraseToAnyPublisher()
            }
            
            return Just(searchQuery)
                .subscribe(on: RunLoop.main)
                .map { text in
                    let filteredEvents = ListMiddlewareHelper.events.filter { event in
                        return event.title.contains(text)
                    }
                    
                    return AppAction.list(.getEventsComplete(events: filteredEvents))
                }
                .eraseToAnyPublisher()
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
}

struct ListMiddlewareHelper {
    private static var dateComponents = Calendar.current.dateComponents([.year], from: Date())
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter
    }()
    
    static var events = [EventViewModel]()
    
    static var firstDayOfYear: String? = {
        dateComponents.calendar = Calendar.current
        dateComponents.day = 1
        dateComponents.month = 1
        
        guard let date = dateComponents.date, dateComponents.isValidDate else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }()
    
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
}
