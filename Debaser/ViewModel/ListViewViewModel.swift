//
//  ListViewViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import Combine
import Foundation

class ListViewViewModel: ObservableObject {
    private let service: EventService
    private let dateFormatter = DateFormatter()
    private var cancellable: AnyCancellable?
    private var dateComponents = Calendar.current.dateComponents([.year], from: Date())
    private var events = [EventViewModel]()
    
    @Published var filteredEvents = [EventViewModel]()
    @Published var isShowingErrorAlert = false
    @Published var currentSearch = ""
    @Published private(set) var isLoading = false
    
    static let networkActivityPublisher = PassthroughSubject<Bool, Never>()
    
    var firstDayOfYear: String? {
        dateComponents.calendar = Calendar.current
        dateComponents.day = 1
        dateComponents.month = 1
                
        guard let date = dateComponents.date, dateComponents.isValidDate else {
            return nil
        }
                
        return dateFormatter.string(from: date)
    }
    
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
    
    var tomorrow: String? {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }
    
    init(service: EventService = EventService()) {
        self.service = service
        
        configure()
    }
    
    private func configure() {
        configureDateFormatter()
        configureSearchPublisher()
    }
    
    private func configureDateFormatter() {
        dateFormatter.dateFormat = "yyyyMMdd"
    }
    
    private func configureSearchPublisher() {
        cancellable = $currentSearch
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] searchText in
                guard let strongSelf = self else { return }
                
                guard !searchText.isEmpty else {
                    strongSelf.filteredEvents = strongSelf.events
                    
                    return
                }
                
                strongSelf.filteredEvents = strongSelf.events.filter { event in
                    let title = event.title
                    
                    return title.contains(searchText)
                }
            })
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
        
        Self.networkActivityPublisher
            .send(true)
        
        service.getEvents(fromDate: from, toDate: to) { [weak self] result in
            DispatchQueue.main.async {
                Self.networkActivityPublisher
                    .send(false)
            }
            
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
                    
                    self?.isShowingErrorAlert = true
                    self?.filteredEvents = []
                }
                
                self?.isLoading = false
            }
        }
    }
}
