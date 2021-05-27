//
//  MapView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-02.
//

import SwiftUI
import MapKit

struct Venue: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Debaser")
                    .font(Font.Variant.large(weight: .semibold).font)
                    .padding(.bottom, 10)

                SeparatorView()
                    .frame(height: 15)
                    .padding(.bottom, 5)

                Group {
                    Text("Hornstulls Strand 9")
                    Text("117 39 Stockholm")
                }
                .font(Font.Variant.small(weight: .regular).font)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            
            MapContentView()
                .cornerRadius(15)
                .padding(.horizontal, 20)
        }
        .background(
            ListViewTopRectangle(),
            alignment: .top
        )
        .background(Color.listBackground)
    }
}

// MARK: - Content

struct MapContentView: View {
    
    // MARK: Private
    
    private let venues: [Venue] = [
        Venue(coordinate: .init(latitude: 59.314805, longitude: 18.031129))
    ]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 59.314805,
            longitude: 18.031129
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.015,
            longitudeDelta: 0.015
        )
    )
    
    @State private var offsetMapPin: CGFloat = -30
    
    private var bounceAnimation: Animation {
        return Animation.timingCurve(
            0.17, 0.67, 0.71, 1.27,
            duration: 0.75
        ).repeatForever(autoreverses: true)
    }
    
    // MARK: Public
    
    var willAnimatePin: Bool
    var pinSize: PinSize
    
    enum PinSize: Int {
        case small
        case large
        
        var scale: CGFloat {
            switch self {
            case .small:
                return 0.65
            case .large:
                return 1.0
            }
        }
    }
    
    init(willAnimatePin: Bool = true, pinSize: PinSize = .large) {
        self.willAnimatePin = willAnimatePin
        self.pinSize = pinSize
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: venues) { venue in
            MapAnnotation(
                coordinate: venue.coordinate,
                anchorPoint: CGPoint(x: 0.5, y: 0.5)
            ) {
                Image("MapPin")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .foregroundColor(.detailMapPinTint)
                    .overlay(
                        Image("Icon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .offset(x: -2, y: -2)
                    )
                    .scaleEffect(pinSize.scale, anchor: .bottom)
                    .offset(y: willAnimatePin ? offsetMapPin : -30)
                    .animation(willAnimatePin ? bounceAnimation : nil)
                    .onAppear {
                        offsetMapPin -= pinSize == .large ? 10 : 5
                    }
            }
        }
        .disabled(true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .preferredColorScheme(.dark)
    }
}
