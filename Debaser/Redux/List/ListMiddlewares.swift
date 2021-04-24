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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        var dateComponents = Calendar.current.dateComponents([.year], from: Date())

        let firstDayOfYear: String? = {
            dateComponents.calendar = Calendar.current
            dateComponents.day = 1
            dateComponents.month = 1
                    
            guard let date = dateComponents.date, dateComponents.isValidDate else {
                return nil
            }
                    
            return dateFormatter.string(from: date)
        }()
        
        let lastDayOfYear: String? = {
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
        
        guard let firstDate = firstDayOfYear, let lastDate = lastDayOfYear else {
            return Empty().eraseToAnyPublisher()
        }

        switch action {
        case .list(.getEventsRequest):
            return service.getPublisher(fromDate: firstDate, toDate: lastDate)
                .subscribe(on: RunLoop.main)
                .map { AppAction.list(.getEventsComplete(events: $0)) }
                .catch { (error: ServiceError) -> Just<AppAction> in
                    Just(AppAction.list(.getEventsError(error: error)))
                }
                .eraseToAnyPublisher()
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
