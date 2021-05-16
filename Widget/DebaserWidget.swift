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
    
    var eventService = EventService.shared
    
    func placeholder(in context: Context) -> DebaserWidgetEntry {
        DebaserWidgetEntry(date: Date(), event: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DebaserWidgetEntry) -> Void) {
        let today = Date()
        
        let formattedToday = dateFormatter.string(from: today)

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
        
        let tomorrow = Calendar.current.date(byAdding: .day, value:1, to: today)
        let midnight = Calendar.current.startOfDay(for: tomorrow ?? today)

        let formattedToday = dateFormatter.string(from: Date())
                
        // Create a date that's one day in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: midnight) ?? today
        
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
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .fontWeight(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundColor(.white)
            .background(Color.widgetMetaData)
            .cornerRadius(10)
    }
}

struct TopView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    let event: EventViewModel?
    
    var isSmall: Bool {
        return widgetFamily == .systemSmall
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: widgetFamily == .systemSmall ? 45 : 50)
                .offset(x: -3)
            
            Spacer()
            
            if let event = event, !event.isCancelled, !event.isPostponed {
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
    @Environment(\.widgetFamily) var widgetFamily

    let event: EventViewModel?

    var isSmall: Bool {
        return widgetFamily == .systemSmall
    }
    
    var shortTodayLabel: LocalizedStringKey {
        return "Widget.Today.Short"
    }

    var longTodayLabel: LocalizedStringKey {
        return "Widget.Today.Long"
    }

    var emptyResultLabel: LocalizedStringKey {
        return "Widget.Result.Empty"
    }
    
    var cancelledLabel: LocalizedStringKey {
        return "Widget.Event.Cancelled"
    }
    
    var postponedLabel: LocalizedStringKey {
        return "Widget.Event.Postponed"
    }
    
    var body: some View {
        guard let event = event else {
            return AnyView(
                HStack(alignment: .top, spacing: 0) {
                    Text(emptyResultLabel)
                        .font(Font.Family.title.of(size: 26))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.01)
                        .lineLimit(3)
                    
                    Spacer()
                }
            )
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if !event.isCancelled, !event.isPostponed {
                        Text(isSmall ? shortTodayLabel : longTodayLabel)
                    } else {
                        if event.isCancelled {
                            Text(cancelledLabel)
                        } else if event.isPostponed {
                            Text(postponedLabel)
                        }
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 13))
                
                HStack(alignment: .top, spacing: 0) {
                    Text(event.title)
                        .font(Font.Family.title.of(size: 26))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.01)
                        .lineLimit(3)
                    
                    Spacer()
                }
            }
        )
    }
}

struct WidgetBackground: View {
    var entry: DebaserWidgetEntry
    
    var body: some View {
        if let event = entry.event {
            if let url = URL(string: event.image),
               let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [.widgetOverlay.opacity(0), .widgetOverlay.opacity(0.85)]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            } else {
                Color.widgetBackground
            }
        } else {
            Color.widgetBackground
        }
    }
}

struct WidgetEntryView: View {
    var entry: DebaserWidgetEntry
    var schemes = "debaser-widget://"
    
    func generateURL(id: String?) -> String {
        guard let id = id else {
            return "invalid"
        }
        
        var components = URLComponents()
        
        let queryItemEvent = URLQueryItem(name: "eventId", value: id)
        components.queryItems = [queryItemEvent]
        
        return "\(schemes)\(components.url?.absoluteString ?? "invalid")"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            TopView(event: entry.event)
            
            Spacer()
            
            BottomView(event: entry.event)
        }
        .padding(15)
        .background(
            WidgetBackground(entry: entry)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: generateURL(id: entry.event?.id)))
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
            .environment(\.locale, .init(identifier: "en"))
        
        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: "en"))
        
        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.locale, .init(identifier: "sv"))

        WidgetEntryView(entry: MockEntry.entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environment(\.locale, .init(identifier: "sv"))
    }
}
