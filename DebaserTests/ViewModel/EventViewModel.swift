//
//  EventViewModel.swift
//  DebaserTests
//
//  Created by Markus Bergh on 2021-04-30.
//

import XCTest
@testable import Debaser

class EventViewModelTests: XCTestCase {
    
    private var viewModel: EventViewModel?
    
    override func setUp() {
        let event = makeEvent()
        
        guard let event = event else {
            XCTFail("There was an error while creating an event")
            
            return
        }
        
        viewModel = EventViewModel(with: event)
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    func testFormattedAdmission() throws {
        let viewModel = try XCTUnwrap(viewModel, "There should be a view model available")
        
        XCTAssertEqual(viewModel.admission, "150 kr")
    }
    
    func testFormattedAgeLimit() throws {
        let viewModel = try XCTUnwrap(viewModel, "There should be a view model available")

        XCTAssertEqual(viewModel.ageLimit, "18 år")
    }
    
    func testFormattedOpenHours() throws {
        let viewModel = try XCTUnwrap(viewModel, "There should be a view model available")
        
        XCTAssertEqual(viewModel.open, "19:00")
    }
    
    func testFormattedSubHeader() throws {
        let viewModel = try XCTUnwrap(viewModel, "There should be a view model available")

        XCTAssertEqual(viewModel.subHeader, "+ New Look")
    }
    
    func testFormattedCancelled() throws {
        let event = makeEvent(cancelled: true)
        let unwrappedEvent = try XCTUnwrap(event, "There should be an event available")
        
        let viewModel = EventViewModel(with: unwrappedEvent)
        
        XCTAssertEqual(viewModel.isCancelled, true)
    }

    func testFormattedPostponed() throws {
        let event = makeEvent(postponed: true)
        let unwrappedEvent = try XCTUnwrap(event, "There should be an event available")
        
        let viewModel = EventViewModel(with: unwrappedEvent)
        
        XCTAssertEqual(viewModel.isPostponed, true)
    }
}

// MARK: Factory methods

extension EventViewModelTests {
    
    private func makeEvent(cancelled: Bool = false, postponed: Bool = false) -> Event? {
        let data = makeData(cancelled: cancelled, postponed: postponed)
        let response = try! JSONDecoder().decode([Event].self, from: data)
        
        guard let event = response.first else {
            XCTFail("There should be a parsed event object available")
            
            return nil
        }

        return event
    }
    
    private func makeData(cancelled: Bool = false, postponed: Bool = false) -> Data {
        var slug = "medis-notix notix medis"
        
        if cancelled {
            slug = slug.replacingOccurrences(of: "notix", with: "cancelled")
        } else if postponed {
            slug = slug.replacingOccurrences(of: "notix", with: "postponed")
        }
        
        let data = Data("""
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
                "VenueSlug": "\(slug)",
                "Room": "Stora scenen",
                "ImageDimensions": "425x230",
                "ImageUrl": "http://debaser.se/img/1357.jpg",
                "TicketUrl": "https://secure.tickster.com/Intro.aspx?ERC=2772TKTKMUDFX28",
                "EventUrl": "http://debaser.se/kalender/3736/"
            }
        ]
        """.utf8)
        
        return data
    }
}
