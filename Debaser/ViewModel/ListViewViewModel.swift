//
//  ListViewViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import Foundation

class ListViewViewModel: ObservableObject {
    private let service: EventService
    private let dateFormatter = DateFormatter()
    
    @Published var events = [Event]()
    @Published var isShowingErrorAlert = false
    @Published private(set) var isLoading = false
    
    init(service: EventService = EventService()) {
        self.service = service
        
        dateFormatter.dateFormat = "yyyyMMdd"
    }
    
    var firstDayOfYear: String? {
        var components = Calendar.current.dateComponents([.year], from: Date())
        
        components.calendar = Calendar.current
        components.day = 1
        components.month = 1
                
        guard let date = components.date, components.isValidDate else {
            return nil
        }
                
        return dateFormatter.string(from: date)
    }
    
    var lastDayOfYear: String? {
        var components = Calendar.current.dateComponents([.year], from: Date())
        
        guard let startDateOfYear = Calendar.current.date(from: components) else {
            return nil
        }

        components.year = 1
        components.day = -1
        
        guard let lastDateOfYear = Calendar.current.date(byAdding: components, to: startDateOfYear) else {
            return nil
        }
        
        return dateFormatter.string(from: lastDateOfYear)
    }
    
    var today: String? {
        return dateFormatter.string(from: Date())
    }
    
    var tomorrow: String? {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }
}

extension ListViewViewModel {
    func fetchAll() {
        guard let fromDate = firstDayOfYear, let toDate = lastDayOfYear else {
            return
        }
        
        fetch(fromDate: fromDate, toDate: toDate)
    }
    
    func fetchToday() {
        guard let fromDate = today, let toDate = today else {
            return
        }

        fetch(fromDate: fromDate, toDate: toDate)
    }
    
    func fetchTomorrow() {
        guard let fromDate = tomorrow, let toDate = tomorrow else {
            return
        }
        
        fetch(fromDate: fromDate, toDate: toDate)
    }
    
    private func fetch(fromDate from: String, toDate to: String) {
        guard !isLoading else { return }
        isLoading = true
        
        service.getEvents(fromDate: from, toDate: to) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.events = events
                case .failure(let error):
                    
                    switch error {
                    case .timeout:
                        ()
                    default:
                        ()
                    }
                    
                    self.isShowingErrorAlert = true
                    self.events = []
                }
                
                self.isLoading = false
            }
        }
    }
}
