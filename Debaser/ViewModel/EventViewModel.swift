//
//  EventViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-17.
//

import Foundation

struct EventViewModel: Codable, Hashable, Identifiable {
    
    /// Id
    var id: String = ""
    
    /// Date
    var date: String = ""
        
    /// Title
    var title: String = "" {
        didSet {
            title = parseTitle(title: &title)
        }
    }
    
    /// Sub header
    var subHeader: String = "" {
        didSet {
            trimWithObscureCharacters(in: &subHeader)
        }
    }
    
    /// Description
    var description: String = "" {
        didSet {
            trimWithObscureCharacters(in: &description)
        }
    }
            
    /// Admission
    var admission: String = "" {
        didSet {
            admission = parseAdmission(admission: &admission)
        }
    }
    
    /// Age limit
    var ageLimit: String = "" {
        didSet {
            ageLimit = parseAgeLimit(ageLimit: &ageLimit)
        }
    }
    
    /// Open hours
    var open: String = "" {
        didSet {
            open = parseOpenHours(openHours: &open)
        }
    }
    
    /// Slug
    var slug: String?
    
    /// Ticket purchase url
    var ticketUrl: String?
    
    /// Venue
    var venue: String = ""
    
    /// Image
    var image: String = ""
            
    init(with event: Event) {
        config(with: event)
    }
    
    private mutating func config(with event: Event) {
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
}

// MARK: - Parsing

extension EventViewModel {
    
    enum Admission: String {
        case free = "fri"
    }
    
    enum RegularExpression: String {
        case titleRegexPattern = #"\S[^->|]+[^ \W]."#
        case admissionRegexPattern = #"\d{1,3} kr"#
        case ageOpenRegexPattern = "\\d{1,2}"
        case openRegexPattern = #"\d{1,2}[.:]\d{1,2}"#
    }
    
    ///
    /// Searches and replaces a string by a provided regular expression
    ///
    /// - Parameters:
    ///     - value: The string to parse
    ///     - regex: The regular expression to use while parsing
    /// - Returns: An optional string
    ///
    private func parse(value: inout String, withRegex regex: EventViewModel.RegularExpression) -> String? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        var matchRange: Range<String.Index>?
        
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue)
            
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
    private func parseTitle(title: inout String) -> String {
        trimWithObscureCharacters(in: &title)

        guard let parsedTitle = parse(value: &title, withRegex: .titleRegexPattern) else {
            return ""
        }
        
        return parsedTitle
    }
    
    /// Parses admission
    private func parseAdmission(admission: inout String) -> String {
        var lowerAdmission = admission.lowercased()

        guard let parsedAdmission = parse(value: &lowerAdmission, withRegex: .admissionRegexPattern) else {
            // Could it be that the admission is for free?
            if isFreeAdmission {
                return NSLocalizedString("Detail.Meta.Admission.Free", comment: "Admission is for free")
            }
            
            // Otherwise just return an empty string, something is odd here
            return ""
        }
        
        return parsedAdmission
    }
    
    /// Parses age limit
    private func parseAgeLimit(ageLimit: inout String) -> String {
        ageLimit = ageLimit.lowercased()
        
        guard let parsedAgeLimit = parse(value: &ageLimit, withRegex: .ageOpenRegexPattern) else {
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
    private func parseOpenHours(openHours: inout String) -> String {
        guard let parsedOpenHours = parse(value: &openHours, withRegex: .openRegexPattern) else {
            
            // I still do not trust you, try and parse once more
            guard let parsedOpenHours = parse(value: &openHours, withRegex: .ageOpenRegexPattern) else {
                return ""
            }
        
            return "\(parsedOpenHours):00"
        }
        
        return parsedOpenHours.replacingOccurrences(of: ".", with: ":")
    }
    
    /// Cleans up a string from occurrences of HTML references
    private func trimWithObscureCharacters(in value: inout String) {
        value = value.replacingOccurrences(of: "&amp;", with: "&")
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
