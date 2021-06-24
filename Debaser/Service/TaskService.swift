//
//  TaskService.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-06-24.
//

import BackgroundTasks
import Combine

final class TaskService {
    static let shared = TaskService()
    
    private let userDefaults = UserDefaults.standard
    private var cancellable: AnyCancellable?
}

extension TaskService {
    func updateToLatestEvents(from task: BGAppRefreshTask, with service: EventService = EventService.shared) {
        guard let firstDate = ListMiddlewareDateHelper.today, let lastDate = ListMiddlewareDateHelper.dateInNearFuture else {
            task.setTaskCompleted(success: false)
            
            return
        }
        
        cancellable = service.getPublisher(fromDate: firstDate, toDate: lastDate)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    task.setTaskCompleted(success: false)
                case .finished:
                    task.setTaskCompleted(success: true)
                }
            }, receiveValue: { events in
                let encoder = JSONEncoder()
                
                if let data = try? encoder.encode(events) {
                    self.userDefaults.set(data, forKey: "se.ejzi.LatestEvents")
                }
            })
    }
}
