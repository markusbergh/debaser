//
//  Event.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import Foundation

struct Event: Decodable, Hashable, Identifiable {
    let id: String
    let name: String
    let status: String
    let description: String
    let ageLimit: String
    let image: String
    let date: String
    let room: String
    let venue: String
}

extension Event {
    enum CodingKeys: String, CodingKey {
        case id = "EventId"
        case name = "Event"
        case status = "EventStatus"
        case description = "Description"
        case ageLimit = "Age"
        case image = "ImageUrl"
        case date = "EventDate"
        case room = "Room"
        case venue = "Venue"
    }
}
