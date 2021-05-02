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
                                .overlay(
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.listRowOverlayGradient.opacity(0.85), .listRowOverlayGradient.opacity(0)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                        } else {
                            Rectangle()
                                .background(Color.clear)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                        }
                        
                        TitleView(title: event.title, fontSize: 33, lineLimit: 3, textColor: .white)
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: 250, maxHeight: 150)
                    }
                    
                    HStack(spacing: 10) {
                        Text(event.listDate)
                            .foregroundColor(.white)
                            .fontWeight(.bold)

                        Spacer()

                        Text(event.venue)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .cornerRadius(15)
                .background(
                    Rectangle()
                        .fill(Color.listRowBackground)
                        .cornerRadius(15)
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
            .buttonStyle(PlainButtonStyle())
        }
        .accentColor(.clear)
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
