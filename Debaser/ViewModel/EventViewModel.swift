//
//  EventViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-17.
//

import Foundation

struct EventViewModel {
    var id: String = ""
    var title: String = "" {
        didSet {
            title = title.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&gt;", with: ">")
        }
    }
    var description: String = ""
    var date: String = ""
    var venue: String = ""
    var image: String = ""
    
    init(with event: Event) {
        configure(event: event)
    }
    
    private mutating func configure(event: Event) {
        id = event.id
        title = event.name
        description = event.description
        date = event.date
        venue = event.venue
        image = event.image
    }
}
