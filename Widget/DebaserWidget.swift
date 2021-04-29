//
//  DebaserWidget.swift
//  Widget
//
//  Created by Markus Bergh on 2021-04-29.
//

import SwiftUI
import WidgetKit

struct EventProvider: TimelineProvider {
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter
    }()
    
    var eventService = EventService()
    
    func placeholder(in context: Context) -> DebaserWidgetEntry {
        DebaserWidgetEntry(date: Date(), event: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DebaserWidgetEntry) -> Void) {
        let today = Date()
        
        let formattedToday = dateFormatter.string(from: Date())

        eventService.getEvents(fromDate: formattedToday, toDate: formattedToday) { response in
            var entry: DebaserWidgetEntry

            switch response {
            case .success(let events):
                // Make sure to only use first
                let firstEvent = events.first
                
                entry = DebaserWidgetEntry(date: today, event: firstEvent)
            case .failure:
                entry = DebaserWidgetEntry(date: today, event: nil)
            }
            
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DebaserWidgetEntry>) -> Void) {
        let today = Date()
        
        let formattedToday = dateFormatter.string(from: Date())
                
        // Create a date that's one day in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        eventService.getEvents(fromDate: formattedToday, toDate: formattedToday) { response in
            var entry: DebaserWidgetEntry

            switch response {
            case .success(let events):
                // Make sure to only use first
                let firstEvent = events.first
                
                entry = DebaserWidgetEntry(date: today, event: firstEvent)
            case .failure:
                entry = DebaserWidgetEntry(date: today, event: nil)
            }
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct DebaserWidgetEntry: TimelineEntry {
    var date = Date()
    var event: EventViewModel?
}

struct MetaData : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var text: String
    
    var isSmall: Bool {
        return widgetFamily == .systemSmall
    }
    
    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .font(.system(size: isSmall ? 11 : 13))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundColor(.white)
            .background(Color.metaData)
            .cornerRadius(10)
    }
}

struct TopView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    let entry: DebaserWidgetEntry
    
    var isSmall: Bool {
        return widgetFamily == .systemSmall
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: widgetFamily == .systemSmall ? 30 : 50)
            
            Spacer()
            
            if let event = entry.event {
                HStack {
                    if !isSmall {
                        MetaData(text: event.ageLimit)
                        MetaData(text: event.admission)
                    }

                    MetaData(text: event.open)
                }
            }
        }
    }
}

struct BottomView : View {
    let entry: DebaserWidgetEntry
    
    var body: some View {
        HStack(alignment: .top) {
            Text(entry.event?.title ?? "Det finns inga kommande event idag")
                .font(Fonts.title.of(size: 26))
                .minimumScaleFactor(0.01)
                .lineLimit(3)
                .foregroundColor(.white)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct WidgetBackground: View {
    var entry: DebaserWidgetEntry
    
    var body: some View {
        if let event = entry.event {
            if let url = URL(string: event.image), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [.overlay.opacity(0), .overlay.opacity(0.75)]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            } else {
                Color.background
            }
        } else {
            Color.background
        }
    }
}

struct WidgetEntryView: View {
    var entry: DebaserWidgetEntry
    var schemes = "debaser-widget://"
    
    func generateURL(id: String) -> String {
        var components = URLComponents()
        
        let queryItemEvent = URLQueryItem(name: "eventId", value: id)
        components.queryItems = [queryItemEvent]
        
        return "\(schemes)\(components.url?.absoluteString ?? "invalid")"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            TopView(entry: entry)
            
            Spacer()
            
            BottomView(entry: entry)
        }
        .padding(15)
        .background(
            WidgetBackground(entry: entry)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@main
struct DebaserWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EventProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Debaser")
        .description("Se dagens event på Debaser.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MockEntry {
    private static let event = Event(
        id: "1234",
        name: "Lydmor",
        subHeader: "",
        status: "",
        description: "",
        ageLimit: "20 år",
        image: "https://debaser.se/img/10981.jpg",
        date: "2021-11-26",
        open: "18:00",
        room: "",
        venue: "",
        slug: "",
        admission: "Fri entré",
        ticketUrl: nil
    )
    
    private static let viewModel = EventViewModel(with: event)
    
    static let entry = DebaserWidgetEntry(date: Date(), event: viewModel)
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
    
        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: "sv"))
        
        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: "sv"))
        
        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.locale, .init(identifier: "sv"))

        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environment(\.locale, .init(identifier: "sv"))
    }
}
