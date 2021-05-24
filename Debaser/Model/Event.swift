//
//  Event.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

struct Event: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let subHeader: String
    let status: String
    let description: String
    let ageLimit: String
    let image: String
    let date: String
    let open: String
    let room: String
    let venue: String
    let slug: String?
    let admission: String
    let ticketUrl: String?
}

extension Event {
    enum CodingKeys: String, CodingKey {
        case id = "EventId"
        case name = "Event"
        case subHeader = "SubHead"
        case status = "EventStatus"
        case description = "Description"
        case ageLimit = "Age"
        case image = "ImageUrl"
        case date = "EventDate"
        case open = "Open"
        case room = "Room"
        case venue = "Venue"
        case slug = "VenueSlug"
        case admission = "Admission"
        case ticketUrl = "TicketUrl"
    }
}
