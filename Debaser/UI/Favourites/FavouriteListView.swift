//
//  FavouriteListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-09.
//

import SwiftUI

struct FavouriteListView: View {
    @EnvironmentObject var store: AppStore
    
    private var titleLabel: LocalizedStringKey {
        return "Favourites"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(store.state.list.favourites, id:\.self) { event in
                        ZStack(alignment: .topTrailing) {
                            FavouriteRowView(event: event)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(.red)
                                )
                                .offset(x: -20, y: 20)
                        }
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 10)
                .padding(.horizontal, 15)
                .navigationTitle(titleLabel)
            }
            .padding(.top, 0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ListViewTopRectangle(),
                alignment: .top
            )
            .background(
                Color.listBackground
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
    }
}
