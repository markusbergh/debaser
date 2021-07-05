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
    @State private var metaVenueButtonScale: CGFloat = 1.0

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
            .modifier(DetailTopMetaHintEffect(to: metaVenueButtonScale) {
                DispatchQueue.main.async {
                    metaVenueButtonScale = 1.0
                }
            })
            .animation(.easeInOut(duration: 0.25))
            .sheet(isPresented: $isShowingMapView) {
                MapView()
                    .preferredColorScheme(colorScheme)
                    .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    metaVenueButtonScale = 1.1
                }
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

struct DetailTopMetaHintEffect: AnimatableModifier {
    var value: CGFloat
    
    private var target: CGFloat
    private var onEneded: () -> ()
    
    init(to value: CGFloat, onEnded: @escaping () -> () = {}) {
        self.value = value
        self.target = value
        self.onEneded = onEnded
    }
    
    var animatableData: CGFloat {
        get { value }
        set {
            value = newValue
            
            // When value has reached the target, we apply the provided callback
            if newValue == target {
                onEneded()
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.scaleEffect(value)
    }
}

struct DetailTopMetaView_Previews: PreviewProvider {
    static var previews: some View {
        let event = EventViewModel.mock
        
        DetailTopMetaView(event: event)
            .previewLayout(.fixed(width: 390, height: 175))
    }
}
