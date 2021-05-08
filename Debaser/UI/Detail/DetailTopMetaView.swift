//
//  DetailTopMetaView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-08.
//

import SwiftUI

struct DetailTopMetaView: View {
    @Environment(\.colorScheme) var colorScheme

    var event: EventViewModel
    
    private var cancelledLabel: String {
        return NSLocalizedString("List.Event.Cancelled", comment: "A cancelled event")
    }
    
    private var postponedLabel: String {
        return NSLocalizedString("List.Event.Postponed", comment: "A postponed event")
    }
    
    @State private var isShowingMapView = false
    
    var body: some View {
        HStack(alignment: .top) {
            if event.isCancelled {
                DetailMetaView(
                    label: cancelledLabel,
                    labelColor: .white,
                    backgroundColor: .red
                )
            } else if event.isPostponed {
                DetailMetaView(
                    label: postponedLabel,
                    labelColor: .white,
                    backgroundColor: .red
                )
            } else {
                Text(event.shortDate)
                    .font(FontVariant.tiny.font)
                    .frame(minHeight: 20)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .strokeBorder(lineWidth: 1.0)
                    )
            }
            
            Button(action: {
                isShowingMapView = true
            }) {
                DetailMetaView(
                    label: event.venue,
                    labelColor: colorScheme == .dark ? .black : .white,
                    backgroundColor: .primary
                )
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $isShowingMapView) {
                MapView()
                    .preferredColorScheme(colorScheme)
                    .ignoresSafeArea()
            }
        }
    }
}
