//
//  FavouriteListEmptyView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-09.
//

import SwiftUI

struct FavouriteListEmptyView: View {
    
    private var emptyLabel: LocalizedStringKey {
        return "Favourites.Empty"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(systemName: "heart.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.favouriteBackgroundIconTint)
                    .frame(width: geometry.size.width * 0.75)
                    .opacity(0.05)
                    .offset(y: 10)
                
                Text(emptyLabel)
                    .font(Font.Variant.smaller(weight: .semibold).font)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
