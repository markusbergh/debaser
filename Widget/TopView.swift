//
//  TopView.swift
//  Widget
//
//  Created by Markus Bergh on 2021-06-10.
//

import SwiftUI

struct TopView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    let event: EventViewModel?
    let isPreview: Bool
    
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

                    MetaData(text: event.openHours)
                }
            } else if isPreview {
                HStack {
                    if !isSmall {
                        MetaData(text: "Age")
                        MetaData(text: "Admission")
                    }

                    MetaData(text: "Open")
                }
                .redacted(reason: .placeholder)
            }
        }
    }
}
