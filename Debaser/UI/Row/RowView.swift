//
//  RowView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import SwiftUI

struct RowView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = ImageViewModel()

    @State private var isShowingDetailView: Bool = false
    
    var event: EventViewModel
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                isShowingDetailView = true
                
                store.dispatch(withAction: .list(.hideTabBar))
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        if store.state.settings.showImages.value == true {
                            Image(uiImage: viewModel.image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                                .clipped()
                                .transition(
                                    .opacity.animation(.easeInOut(duration: 0.2))
                                )
                        } else {
                            Rectangle()
                                .background(Color.clear)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                        }
                        
                        TitleView(title: event.title, fontSize: 35, lineLimit: 2, textColor: .white)
                            .frame(maxWidth: 250)
                            .fixedSize(horizontal: false, vertical: true)
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                            .padding(.top, 30)
                            .padding(.leading, 25)
                    }

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
                .cornerRadius(15)
                .background(
                    Rectangle()
                        .fill(Color.listRowBackground)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: -5)
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
            .accentColor(.clear)
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event
        
        RowView(event: event)
            .environmentObject(store)
    }
}
