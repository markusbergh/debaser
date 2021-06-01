//
//  DetailTopMetaView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-08.
//

import SwiftUI

struct DetailTopMetaView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingMapView = false
    
    private var cancelledLabel: String {
        return NSLocalizedString("List.Event.Cancelled", comment: "A cancelled event")
    }
    
    private var postponedLabel: String {
        return NSLocalizedString("List.Event.Postponed", comment: "A postponed event")
    }
    
    private var isEventNextYear: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: event.date) else {
            return false
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let eventYear = Calendar.current.component(.year, from: date)
        
        if currentYear < eventYear {
            return true
        }
        
        return false
    }
    
    let event: EventViewModel

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
                    .font(Font.Variant.tiny.font)
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
            
            if isEventNextYear {
                Text(event.shortYear)
                    .font(Font.Variant.tiny.font)
                    .frame(minHeight: 20)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .strokeBorder(lineWidth: 1.0)
                    )
            }
        }
    }
}

struct DetailTopMetaView_Previews: PreviewProvider {
    static var previews: some View {
        let event = MockEventViewModel.event
        
        DetailTopMetaView(event: event)
            .previewLayout(.fixed(width: 390, height: 175))
    }
}
