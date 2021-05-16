//
//  MessagesViewViewModel.swift
//  iMessage
//
//  Created by Markus Bergh on 2021-04-27.
//

import Foundation

class MessagesViewViewModel {
    private var dateComponents = Calendar.current.dateComponents([.year], from: Date())
    private let dateFormatter = DateFormatter()
    private let service: EventService
    
    var events = [EventViewModel]()
    var filteredEvents = [EventViewModel]()
    
    init(service: EventService = EventService()) {
        self.service = service
        
        configure()
    }
    
    private func configure() {
        configureDateFormatter()
    }
    
    private func configureDateFormatter() {
        dateFormatter.dateFormat = "yyyyMMdd"
    }
}

extension MessagesViewViewModel {
    var lastDayOfYear: String? {
        guard let startDateOfYear = Calendar.current.date(from: dateComponents) else {
            return nil
        }

        dateComponents.year = 1
        dateComponents.day = -1
        
        guard let lastDateOfYear = Calendar.current.date(byAdding: dateComponents, to: startDateOfYear) else {
            return nil
        }
        
        return dateFormatter.string(from: lastDateOfYear)
    }
    
    var today: String? {
        return dateFormatter.string(from: Date())
    }

    
    func getEvents(completion: @escaping () -> Void) {
        guard let today = today else { return }
        guard let lastDayOfYear = lastDayOfYear else { return }
        
        service.getEvents(fromDate: today, toDate: lastDayOfYear) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self?.events = events
                    self?.filteredEvents = events
                case .failure(let error):
                    
                    switch error {
                    case .timeout:
                        ()
                    default:
                        ()
                    }
                    
                    self?.filteredEvents = []
                }
                
                completion()
            }
        }
    }
    
    func getEventDateFormat(date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"

        let locale = Locale(identifier: Locale.preferredLanguages[0])

        if let date = dateFormatter.date(from: date) {
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "d MMM"

            return dateFormatter.string(from: date)
        }

        return nil
    }
}
