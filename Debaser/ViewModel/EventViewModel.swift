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
    var slug: String?
    var ticketUrl: String?
    
    @ParseUsingRegularExpression(pattern: .title) var title: String
    @ParseUsingRegularExpression(pattern: .ageLimitOrOpenHours) var ageLimit: String
    @ParseUsingRegularExpression(pattern: .admission) var admission: String
    @ParseUsingRegularExpression(pattern: .openHours) var openHours: String
    
    @TrimObscureHTMLCharacter var subHeader: String
    @TrimObscureHTMLCharacter var description: String

    // MARK: Initializer
    
    init(with event: Event) {
        id = event.id
        date = event.date
        venue = event.venue
        image = event.image
        slug = event.slug
        ticketUrl = event.ticketUrl
        title = event.name
        ageLimit = event.ageLimit
        admission = event.admission
        openHours = event.openHours
        subHeader = event.subHeader
        description = event.description
    }
}

// MARK: - Parsing

@propertyWrapper
struct TrimObscureHTMLCharacter: Codable, Hashable {
    private(set) var value = ""
    
    var wrappedValue: String {
        get { value }
        set {
            let elementsToReplace = [
                "&amp;": "&",
                "&gt;": ">",
                "&nbsp;": " ",
                "&quot;": "\""
            ]
            
            // Make a copy of the value
            var parsedValue = newValue
            
            // Iterate through each occurrance
            for (element, replacement) in elementsToReplace {
                parsedValue = parsedValue.replacingOccurrences(of: element, with: replacement)
            }
            
            value = parsedValue
        }
    }
}

@propertyWrapper
struct ParseUsingRegularExpression {
    private(set) var value: String = ""
    private(set) var pattern: RegularExpressionPattern?
    
    /// Admission type
    enum Admission: String {
        case free = "fri"
    }
    
    /// Pattern options
    enum RegularExpressionPattern: String {
        case admission = #"\d{1,3} kr"#
        case ageLimitOrOpenHours = "\\d{1,2}"
        case title = #"\S[^->|]+[^ \W]."#
        case openHours = #"\d{1,2}[.:]\d{1,2}"#
    }
    
    init(pattern: RegularExpressionPattern) {
        self.pattern = pattern
    }

    var wrappedValue: String {
        get { value }
        set {
            guard let parsedValue = parse(value: newValue) else {
                return value = clean(value: newValue)
            }
            
            value = clean(value: parsedValue)
        }
    }
    
    // MARK: Parse
    
    ///
    /// Parses a `value` with a set regular expression
    ///
    /// - Parameters:
    ///   - value: The string value to parse
    /// - Returns: An optional parsed string
    ///
    private func parse(value: String) -> String? {
        guard let pattern = pattern else { return nil }
        
        return parse(value: value, pattern: pattern)
    }
    
    ///
    /// Parses a `value` with a provided regular expression
    ///
    /// - Parameters:
    ///   - value: The string value to parse
    ///   - pattern: Regular expression to parse with
    /// - Returns: An optional parsed string
    ///
    private func parse(value: String, pattern: RegularExpressionPattern) -> String? {
        let value = value.lowercased()
        
        do {
            let range = NSRange(value.startIndex..<value.endIndex, in: value)
            let regex = try NSRegularExpression(pattern: pattern.rawValue, options: [.caseInsensitive])
        
            guard let match = regex.firstMatch(in: value, options: [], range: range) else {
                return nil
            }
            
            let matchRange = match.range(at: 0)

            guard let stringRange = Range(matchRange, in: value) else {
                return nil
            }
            
            return String(value[stringRange])
        } catch {
            return nil
        }
    }
    
    // MARK: Clean
    
    ///
    /// Cleans up a `value` after parsing is done
    ///
    /// - Parameters:
    ///   - value: The string value to clean
    /// - Returns: A string
    ///
    private func clean(value: String) -> String {
        guard let pattern = pattern else { return value }

        var updatedValue = value
        
        switch pattern {
        
        /// Cleans up a string from occurrences of HTML references
        case .title:
            updatedValue = value.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        
        /// Sets a formatted string for age limit
        case .ageLimitOrOpenHours:
            func formattedAgeLimit(_ value: String) -> String {
                let localizedAgeLimit = NSLocalizedString("Detail.Age", comment: "Age limit")
                
                return String(format: localizedAgeLimit, value)
            }
            
            updatedValue = formattedAgeLimit(value)
        
        /// Event admission might be for free
        case .admission:
            if value.contains(Admission.free.rawValue) {
                updatedValue = NSLocalizedString("Detail.Meta.Admission.Free", comment: "Admission is for free")
            }
            
        /// Retry some parsing if needed
        case .openHours:
            
            // I still do not trust you, try and parse once more
            guard let parsedOpenHours = parse(value: value, pattern: .ageLimitOrOpenHours) else {
                updatedValue = value.replacingOccurrences(of: ".", with: ":")
                break
            }
        
            updatedValue = "\(parsedOpenHours):00"
        }
        
        return updatedValue
    }
}

extension ParseUsingRegularExpression: Codable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        value = try values.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension ParseUsingRegularExpression: Hashable {
    static func == (lhs: ParseUsingRegularExpression, rhs: ParseUsingRegularExpression) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

// MARK: - Status

extension EventViewModel {
    
    /// Free admission string
    enum Admission: String {
        case free = "fri"
    }
    
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
            openHours: "Öppnar kl 18:30",
            room: "Bar Brooklyn",
            venue: "Strand",
            slug: "",
            admission: "250 kr",
            ticketUrl: nil
        )
        
        return EventViewModel(with: event)
    }
}
