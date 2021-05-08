//
//  Event.swift
//  
//
//  Created by Markus Bergh on 2021-05-08.
//

public struct Event: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let subHeader: String
    public let status: String
    public let description: String
    public let ageLimit: String
    public let image: String
    public let date: String
    public let open: String
    public let room: String
    public let venue: String
    public let slug: String?
    public let admission: String
    public let ticketUrl: String?
    
    public init(id: String, name: String, subHeader: String, status: String, description: String, ageLimit: String, image: String, date: String, open: String, room: String, venue: String, slug: String, admission: String, ticketUrl: String?) {
        self.id = id
        self.name = name
        self.subHeader = subHeader
        self.status = status
        self.description = description
        self.ageLimit = ageLimit
        self.image = image
        self.date = date
        self.open = open
        self.room = room
        self.venue = venue
        self.slug = slug
        self.admission = admission
        self.ticketUrl = ticketUrl
    }
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
