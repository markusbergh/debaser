//
//  MapView.swift
//  ShowOnMap
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
    @State private var venues: [Venue] = [
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
    
    private var bounceAnimation: Animation {
        return Animation.timingCurve(
            0.17, 0.67, 0.71, 1.27,
            duration: 0.75
        ).repeatForever(autoreverses: true)
    }
    
    @State private var offsetMapPin: CGFloat = -30
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Debaser")
                    .font(.system(size: 29))
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)

                SeparatorView()
                    .frame(height: 15)
                    .padding(.bottom, 5)

                Text("Hornstulls Strand 9")
                    .font(.system(size: 17))
                Text("117 39 Stockholm")
                    .font(.system(size: 17))
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            
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
                        .offset(y: offsetMapPin)
                        .animation(bounceAnimation)
                        .onAppear {
                            offsetMapPin -= 10
                        }
                }
            }
            .cornerRadius(15)
            .padding(.horizontal, 20)
            .disabled(true)
        }
        .background(
            ListViewTopRectangle(),
            alignment: .top
        )
        .background(Color.listBackground)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .preferredColorScheme(.dark)
    }
}
