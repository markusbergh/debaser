//
//  Event.swift
//  DebaserTests
//
//  Created by Markus Bergh on 2021-04-05.
//

import XCTest
@testable import Debaser

class EventTests: XCTestCase {
    func testParseSingleEvent() {
        let response = try! JSONDecoder().decode([Event].self, from: EventTests.event)
        
        XCTAssertEqual(response.count, 1)
        
        guard let event = response.first else {
            XCTFail("There should be a parsed event object available")
            
            return
        }
        
        XCTAssertEqual(event.id, "3736")
        XCTAssertEqual(event.date, "2010-01-19")
        XCTAssertEqual(event.status, "Slutsålt")
        XCTAssertEqual(event.name, "The Xx")
        XCTAssertEqual(event.subHeader, " + New Look")
        XCTAssertEqual(event.ageLimit, "18 (20 efter konsert)")
        XCTAssertEqual(event.openHours, "Inne 19-01")
        XCTAssertEqual(event.admission, "150 kr + förköpsavgift. Biljetter finns hos Tickster, Sound Pollution, Record Hunter, Pet Sounds.")
        XCTAssertEqual(event.venue, "Medis")
        XCTAssertEqual(event.slug, "medis-notix notix medis")
        XCTAssertEqual(event.image, "http://debaser.se/img/1357.jpg")
        XCTAssertEqual(event.ticketUrl, "https://secure.tickster.com/Intro.aspx?ERC=2772TKTKMUDFX28")
    }
}

extension EventTests {
    private static let event = Data("""
    [
        {
            "EventId": "3736",
            "EventDate": "2010-01-19",
            "EventStatus": "Slutsålt",
            "Event": "The Xx",
            "SubHead": " + New Look",
            "TableBooking": "",
            "Description": "\\n",
            "Age": "18 (20 efter konsert)",
            "Open": "Inne 19-01",
            "Admission": "150 kr + förköpsavgift. Biljetter finns hos Tickster, Sound Pollution, Record Hunter, Pet Sounds.",
            "Venue": "Medis",
            "VenueSlug": "medis-notix notix medis",
            "Room": "Stora scenen",
            "ImageDimensions": "425x230",
            "ImageUrl": "http://debaser.se/img/1357.jpg",
            "TicketUrl": "https://secure.tickster.com/Intro.aspx?ERC=2772TKTKMUDFX28",
            "EventUrl": "http://debaser.se/kalender/3736/"
        }
    ]
    """.utf8)
}
