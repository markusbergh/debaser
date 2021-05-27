//
//  FavouriteListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-09.
//

import SwiftUI

struct FavouriteListView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private
    
    private let listPadding: CGFloat = 20
    private let itemSpacing: CGFloat = 25
    private let itemHeight: CGFloat = 170
    
    private var titleLabel: LocalizedStringKey {
        return "Favourites"
    }
    
    private var listBottomPadding: CGFloat {
        return TabBarStyle.paddingBottom.rawValue + TabBarStyle.height.rawValue + listPadding
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: itemSpacing) {
                ForEach(store.state.list.favourites, id:\.self) { event in
                    ZStack(alignment: .topTrailing) {
                        FavouriteRowView(event: event, totalHeight: itemHeight)
                        
                        FavouriteListHeartSymbolView()
                    }
                    .frame(height: itemHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 10)
            .padding(.horizontal, listPadding)
            .padding(.bottom, listBottomPadding)
            .navigationTitle(titleLabel)
        }
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

// MARK: - Heart symbol

struct FavouriteListHeartSymbolView: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.red)
            )
            .offset(x: -20, y: 20)
    }
}

struct FavouriteListView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        
        FavouriteListView()
            .environmentObject(store)
    }
}

