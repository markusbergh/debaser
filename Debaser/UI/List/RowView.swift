//
//  RowView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import SwiftUI

struct RowView: View {
    @AppStorage("showImages") var showImages: Bool = true
    @StateObject var viewModel: RowViewViewModel = RowViewViewModel()
    
    @State private var isShowingDetailView: Bool = false
    
    var event: EventViewModel
    var willShowInfoBar = true
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                // TODO:
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 150)
                        
                        if showImages {
                            Image(uiImage: viewModel.image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                                .clipped()
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                                .overlay(
                                    Rectangle().fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.black, .clear]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                )
                        } else {
                            Rectangle()
                                .background(Color.red)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                        }

                        Text(event.title)
                            .lineLimit(2)
                            .font(Fonts.title.of(size: 31))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0, y: 0)
                            .frame(minWidth: 0, maxWidth: 275, alignment: .leading)
                            .offset(x: 20, y: 15)
                            .multilineTextAlignment(.leading)
                    }
                    .cornerRadius(15)

                    if willShowInfoBar {
                        HStack(spacing: 15) {
                            DetailMetaView(
                                image: "person",
                                label: "20 år",
                                backgroundColor: .detailViewMetaPrimary
                            )
                            DetailMetaView(
                                image: "banknote",
                                label: "150 kr",
                                backgroundColor: .detailViewMetaSecondary
                            )
                            DetailMetaView(
                                image: "clock",
                                label: "18:00",
                                backgroundColor: .detailViewMetaTertiary
                            )
                        }
                        .padding()
                    }
                }
                .cornerRadius(15)
                .background(
                    Rectangle()
                        .fill(Color.listRowBackground)
                        .cornerRadius(15)
                        .shadow(
                            color: Color.black.opacity(0.25),
                            radius: 20,
                            x: 0,
                            y: -5
                        )

                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .circular)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [Color.listRowStrokeGradientStart, Color.listRowStrokeGradientEnd]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        ).opacity(0.5)
                )
                .onAppear {
                    viewModel.loadImage(with: event.image)
                }
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(id: "1234",
                          name: "MR MS",
                          subHeader: "",
                          status: "Open",
                          description: "Lorem ipsum dolor",
                          ageLimit: "18 år",
                          image: "https://debaser.se/img/10982.jpg",
                          date: "2010-01-19",
                          open: "Öppnar kl 18:30",
                          room: "Bar Brooklyn",
                          venue: "Strand",
                          slug: nil,
                          admission: "Fri entre",
                          ticketUrl: nil)
        
        let model = EventViewModel(with: event)
        
        RowView(event: model)
    }
}
