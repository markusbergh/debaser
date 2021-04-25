//
//  EventViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-17.
//

import Foundation

struct EventViewModel: Hashable {
    var id: String = ""
    var title: String = "" {
        didSet {
            title = title.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&gt;", with: ">")

            guard let trimmedTitle = trim(value: &title, withRegex: "\\S[^->|]+[^ \\W].") else {
                return
            }
            
            title = trimmedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var subHeader: String = "" {
        didSet {
            subHeader = subHeader.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var description: String = "" {
        didSet {
            description = description.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&nbsp;", with: " ")
        }
    }
    var date: String = ""
    var venue: String = ""
    var image: String = ""
    var admission: String = "" {
        didSet {
            var lowerAdmission = admission.lowercased()

            guard let trimmedAdmission = trim(value: &lowerAdmission, withRegex: "\\d{1,3} kr") else {
                // Quick and dirty check if admission might be for free
                if admission.contains("Fri") {
                    isFreeAdmission = true
                }
                
                return
            }
            
            admission = trimmedAdmission
        }
    }
    var ageLimit: String = "" {
        didSet {
            ageLimit = ageLimit.lowercased()
            
            guard let trimmedAgeLimit = trim(value: &ageLimit, withRegex: "\\d{1,2}") else {
                return
            }
            
            func formattedAgeLimit(_ value: String) -> String {
                let localizedAgeLimit = NSLocalizedString("Detail.Age", comment: "Age limit")
                
                return String(format: localizedAgeLimit, value)
            }
            
            ageLimit = formattedAgeLimit(trimmedAgeLimit)
        }
    }
    var open: String = "" {
        didSet {
            guard let trimmedOpen = trim(value: &open, withRegex: "\\d{1,2}[.:]\\d{1,2}") else {
                // Try and parse differently
                guard let trimmedOpen = trim(value: &open, withRegex: "\\d{1,2}") else {
                    return
                }
            
                open = "\(trimmedOpen):00"
        
                return
            }
            
            open = trimmedOpen.replacingOccurrences(of: ".", with: ":")
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
    
    private func trim(value: inout String, withRegex regex: String) -> String? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        let regex = try! NSRegularExpression(pattern: regex)
        
        guard let match = regex.firstMatch(in: value, options: [], range: range),
              let stringRange = Range(match.range(at: 0), in: value) else {
            return nil
        }
        
        return String(value[stringRange])
    }
}
