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
    @Binding var isShowingTabBar: Bool

    private var title: String = ""
    
    var event: EventViewModel
    var willShowInfoBar = false
    
    init(event: EventViewModel, isShowingTabBar: Binding<Bool>) {
        self.event = event
        self._isShowingTabBar = isShowingTabBar
        
        title = event.title
    }
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                self.isShowingTabBar = true
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 175)
                        
                        if showImages {
                            Image(uiImage: viewModel.image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 175)
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
                                .frame(height: 175)
                        }

                        Text(title)
                            .font(.system(size: 23, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0, y: 0)
                            .frame(minWidth: 0, maxWidth: 275, alignment: .leading)
                            .offset(x: 20, y: 20)
                            .multilineTextAlignment(.leading)
                    }
                    .cornerRadius(15)

                    if willShowInfoBar {
                        HStack(spacing: 15) {
                            Spacer()
                            Group {
                                Text("24 SEP")
                                    .fontWeight(.bold)
                                Text("18:00")
                                    .fontWeight(.bold)
                                Text("250 SEK")
                                    .fontWeight(.bold)
                            }
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold,
                                    design: .default
                                )
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
                            color: Color.listRowShadowBackground.opacity(0.2),
                            radius: 20,
                            x: 0.0,
                            y: 10.0
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
                          status: "Open",
                          description: "Lorem ipsum dolor",
                          ageLimit: "18 år",
                          image: "https://debaser.se/img/10982.jpg",
                          date: "2010-01-19",
                          room: "Bar Brooklyn",
                          venue: "Strand")
        
        let model = EventViewModel(with: event)
        
        RowView(
            event: model,
            isShowingTabBar: .constant(false)
        )
    }
}
