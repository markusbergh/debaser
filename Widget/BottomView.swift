//
//  DebaserWidgetBottomView.swift
//  Widget
//
//  Created by Markus Bergh on 2021-06-10.
//

import SwiftUI

struct BottomView : View {
    @Environment(\.widgetFamily) var widgetFamily

    let event: EventViewModel?
    let isPreview: Bool

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
    
    var previewView: some View {
        return HStack(alignment: .top, spacing: 0) {
            Text("This is an event")
                .font(Font.Family.title.of(size: 26))
                .foregroundColor(.white)
                .minimumScaleFactor(0.01)
                .lineLimit(3)
            
            Spacer()
        }
    }
    
    var emptyView: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(emptyResultLabel)
                .font(Font.Family.title.of(size: 26))
                .foregroundColor(.white)
                .minimumScaleFactor(0.01)
                .lineLimit(3)
            
            Spacer()
        }
    }
    
    var body: some View {
        if isPreview {
            return AnyView(previewView)
        }
        
        guard let event = event else {
            return AnyView(emptyView)
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if event.isCancelled {
                        Text(cancelledLabel)
                    } else if event.isPostponed {
                        Text(postponedLabel)
                    } else {
                        Text(isSmall ? shortTodayLabel : longTodayLabel)
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
