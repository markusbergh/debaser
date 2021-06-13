//
//  EventViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-17.
//

import Foundation

struct EventViewModel: Codable, Hashable, Identifiable {
    
    // MARK: Properties
    
    let id: String
    let date: String
    let venue: String
    let image: String
    let title: String!
    let subHeader: String
    let description: String
    let ageLimit: String
    let admission: String
    let open: String
    var slug: String?
    var ticketUrl: String?
    
    // MARK: Initializer
    
    init(with event: Event) {
        id = event.id
        date = event.date
        venue = event.venue
        image = event.image
        slug = event.slug
        ticketUrl = event.ticketUrl
        
        // These needs some parsing unfortunately
        title = EventViewModel.parse(title: event.name)
        ageLimit = EventViewModel.parse(ageLimit: event.ageLimit)
        admission = EventViewModel.parse(admission: event.admission)
        open = EventViewModel.parse(openHours: event.open)
        
        // And these needs some trimming
        subHeader = EventViewModel.trimWithObscureCharacters(in: event.subHeader)
        description = EventViewModel.trimWithObscureCharacters(in: event.description)
    }
}

// MARK: - Parsing

extension EventViewModel {
    
    /// Admission type
    enum Admission: String {
        case free = "fri"
    }
    
    /// Expression patterns
    enum RegularExpressionPattern: String {
        case title = #"\S[^->|]+[^ \W]."#
        case admission = #"\d{1,3} kr"#
        case ageLimitOpenHours = "\\d{1,2}"
        case openHours = #"\d{1,2}[.:]\d{1,2}"#
    }
    
    ///
    /// Searches and replaces a string by a provided regular expression
    ///
    /// - Parameters:
    ///     - value: The string to parse
    ///     - pattern: The regular expression to use while parsing
    /// - Returns: An optional string
    ///
    private static func parse(value: String, withRegex pattern: EventViewModel.RegularExpressionPattern) -> String? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        var matchRange: Range<String.Index>?
        
        do {
            let regex = try NSRegularExpression(pattern: pattern.rawValue)
            
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

        
    /// Parses title
    private static func parse(title: String) -> String {
        let trimmedTitle = trimWithObscureCharacters(in: title)

        guard let parsedTitle = parse(value: trimmedTitle, withRegex: .title) else {
            return ""
        }
        
        return parsedTitle
    }
    
    /// Parses admission
    private static func parse(admission: String) -> String {
        let lowerAdmission = admission.lowercased()

        guard let parsedAdmission = parse(value: lowerAdmission, withRegex: .admission) else {
            // Could it be that the admission is for free?
            if lowerAdmission.lowercased().contains(Admission.free.rawValue) {
                return NSLocalizedString("Detail.Meta.Admission.Free", comment: "Admission is for free")
            }
            
            // Otherwise just return an empty string, something is odd here
            return ""
        }
        
        return parsedAdmission
    }
    
    /// Parses age limit
    private static func parse(ageLimit: String) -> String {
        let ageLimit = ageLimit.lowercased()
        
        guard let parsedAgeLimit = parse(value: ageLimit, withRegex: .ageLimitOpenHours) else {
            return ""
        }
        
        func formattedAgeLimit(_ value: String) -> String {
            let localizedAgeLimit = NSLocalizedString("Detail.Age", comment: "Age limit")
            
            return String(format: localizedAgeLimit, value)
        }
        
        // Needs a formatted string with value
        return formattedAgeLimit(parsedAgeLimit)
    }
    
    /// Parses open hours
    private static func parse(openHours: String) -> String {
        guard let parsedOpenHours = parse(value: openHours, withRegex: .openHours) else {
            
            // I still do not trust you, try and parse once more
            guard let parsedOpenHours = parse(value: openHours, withRegex: .ageLimitOpenHours) else {
                return ""
            }
        
            return "\(parsedOpenHours):00"
        }
        
        return parsedOpenHours.replacingOccurrences(of: ".", with: ":")
    }
    
    /// Cleans up a string from occurrences of HTML references
    private static func trimWithObscureCharacters(in value: String) -> String {
        return value
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

// MARK: - Status

extension EventViewModel {
    
    /// Returns a Boolean based on if event is cancelled
    var isCancelled: Bool {
        return slug?.contains("cancelled") ?? false
    }
    
    /// Returns a Boolean based on if event is postponed
    var isPostponed: Bool {
        return slug?.contains("postponed") ?? false
    }

    /// Returns a Boolean based on if event is of free admission
    var isFreeAdmission: Bool {
        return admission.lowercased().contains(Admission.free.rawValue)
    }

}

// MARK: - Date

extension EventViewModel {
    
    /// Returns a date string in format of `d/M`
    var shortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "d/M"
        
        return dateFormatter.string(from: date)
    }
    
    /// Returns a date string in format of `d MMM`
    var listDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter.string(from: date)
    }
    
    /// Return a date string in format of `yyyy`
    var shortYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    /// Returns a Boolean based on if event date is overdue
    var isDateExpired: Bool {
        let today = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let eventDate = dateFormatter.date(from: date) else {
            return false
        }
        
        guard let daysSince = Calendar.current.dateComponents([.day], from: eventDate, to: today).day else {
            return false
        }
        
        if daysSince > 0 {
            return true
        }
        
        return false
    }
    
}

// MARK: - Mock event

extension EventViewModel {
    static var mock: EventViewModel {
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
