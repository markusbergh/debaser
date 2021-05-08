//
//  EventViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-17.
//

import Foundation
import DebaserService

struct EventViewModel: Codable, Hashable, Identifiable {
    static let titleRegexPattern = #"\S[^->|]+[^ \W]."#
    static let admissionRegexPattern = #"\d{1,3} kr"#
    static let ageRegexPattern = "\\d{1,2}"
    static let openRegexPattern = #"\d{1,2}[.:]\d{1,2}"#
    static let openRegexAdditionalPattern = #"\d{1,2}"#
    
    var id: String = ""
    var title: String = "" {
        didSet {
            title = trimWithObscureCharacters(title)

            guard let parsed = parse(value: &title, withRegex: EventViewModel.titleRegexPattern) else {
                return
            }
            
            title = parsed.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var subHeader: String = "" {
        didSet {
            subHeader = trimWithObscureCharacters(subHeader)
        }
    }
    var description: String = "" {
        didSet {
            description = trimWithObscureCharacters(description)
        }
    }
    var date: String = ""
    var venue: String = ""
    var image: String = ""
    var admission: String = "" {
        didSet {
            var lowerAdmission = admission.lowercased()

            guard let parsedValue = parse(value: &lowerAdmission, withRegex: EventViewModel.admissionRegexPattern) else {
                // Quick and dirty check if admission might be for free
                if lowerAdmission.contains("fri") {
                    isFreeAdmission = true
                }
                
                return
            }
            
            admission = parsedValue
        }
    }
    var ageLimit: String = "" {
        didSet {
            ageLimit = ageLimit.lowercased()
            
            guard let parsedValue = parse(value: &ageLimit, withRegex: EventViewModel.ageRegexPattern) else {
                return
            }
            
            func formattedAgeLimit(_ value: String) -> String {
                let localizedAgeLimit = NSLocalizedString("Detail.Age", comment: "Age limit")
                
                return String(format: localizedAgeLimit, value)
            }
            
            // Needs a formatted string with value
            ageLimit = formattedAgeLimit(parsedValue)
        }
    }
    var open: String = "" {
        didSet {
            guard let parsedValue = parse(value: &open, withRegex: EventViewModel.openRegexPattern) else {
                
                // I still do not trust you, try and parse once more
                guard let parsedValue = parse(value: &open, withRegex: EventViewModel.openRegexAdditionalPattern) else {
                    return
                }
            
                open = "\(parsedValue):00"
        
                return
            }
            
            open = parsedValue.replacingOccurrences(of: ".", with: ":")
        }
    }
    var slug: String?
    var ticketUrl: String?
    var isFreeAdmission = false
    var isCancelled: Bool {
        return slug?.contains("cancelled") ?? false
    }
    var isPostponed: Bool {
        return slug?.contains("postponed") ?? false
    }
    
    init(with event: Event) {
        configure(event: event)
    }
    
    private mutating func configure(event: Event) {
        id = event.id
        title = event.name
        subHeader = event.subHeader
        description = event.description
        date = event.date
        venue = event.venue
        image = event.image
        open = event.open
        slug = event.slug
        admission = event.admission
        ageLimit = event.ageLimit
        ticketUrl = event.ticketUrl
    }
    
    private func parse(value: inout String, withRegex regex: String) -> String? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        var matchRange: Range<String.Index>?
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            
            autoreleasepool {
                guard let match = regex.firstMatch(in: value, options: [], range: range) else {
                    return
                }
                
                let range = match.range(at: 0)

                guard let stringRange = Range(range, in: value) else {
                    return
                }
                
                matchRange = stringRange
            }
            
            guard let matchRange = matchRange else {
                return nil
            }

            return String(value[matchRange])
        } catch {
            return nil
        }
    }
    
    private func trimWithObscureCharacters(_ value: String) -> String {
        return value.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension EventViewModel {
    var shortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "d/M"
        
        return dateFormatter.string(from: date)
    }
    
    var listDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter.string(from: date)
    }
}

// MARK: Mock event

class MockEventViewModel {
    static var event: EventViewModel {
        let event = Event(
            id: "1234",
            name: "Rocket From The Crypt",
            subHeader: "This is a subheader text.",
            status: "Open",
            description: "The Other Favorites is the long time duo project of Carson McKee and Josh Turner. Perhaps best known for their performances on YouTube, which have garnered millions of views. The Other Favorites are now based out of Brooklyn, NY. Together, Turner and McKee bring their shared influences of folk, bluegrass and classic rock into a modern framework; one distinguished by incisive songwriting, virtuosic guitar work and tight two-part harmony.\n\nReina del Cid is a singer songwriter and leader of the eponymous folk rock band based in Los Angeles. Her song-a-week video series, Sunday Mornings with Reina del Cid, has amassed 40 million views on YouTube and collected a diverse following made up of everyone from jamheads to college students to white-haired intelligentsia. In 2011 she began collaborating with Toni Lindgren, who is the lead guitarist on all three of Del Cid’s albums, as well as a frequent and much beloved guest on the Sunday Morning videos. The two have adapted their sometimes hard-hitting rock ballads and catchy pop riffs into a special acoustic duo set.",
            ageLimit: "18 år",
            image: "https://debaser.se/img/10982.jpg",
            date: "2010-01-19",
            open: "Öppnar kl 18:30",
            room: "Bar Brooklyn",
            venue: "Strand",
            slug: "",
            admission: "250 kr",
            ticketUrl: nil
        )
        
        return EventViewModel(with: event)
    }
}
