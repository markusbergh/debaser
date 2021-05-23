//
//  ListRowImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-23.
//

import SwiftUI

struct ListRowImageView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var viewModel: ImageViewModel

    @State private var opacity: Double = 0
    
    private var showImagesIfNeeded: Bool {
        return store.state.settings.showImages.value == true
    }

    var mediaHeight: CGFloat?

    var body: some View {
        if showImagesIfNeeded {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: mediaHeight)
                .cornerRadius(15)
                .opacity(opacity)
                .onReceive(viewModel.$isLoaded) { isLoaded in
                    if isLoaded {
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                }
        } else {
            Rectangle()
                .fill(Color.listRowBackground)
                .frame(height: mediaHeight)
                .cornerRadius(15)
        }
    }
}

struct ListRowImageViewModifier: ViewModifier {
    @EnvironmentObject var store: AppStore

    var isCancelled = false
    var isPostponed = false
    var maxHeight: CGFloat
    
    func body(content: Content) -> some View {
        let opacity = store.state.settings.showImages.value ? 0.5 : 0.0
    
        if isCancelled {
            return AnyView(
                ZStack(alignment: .center) {
                    content
                    Text("List.Event.Cancelled")
                        .font(Font.Variant.body(weight: .bold).font)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(opacity))
                        .cornerRadius(15)
                }
            )
        } else if isPostponed {
            return AnyView(
                ZStack(alignment: .center) {
                    content
                    Text("List.Event.Postponed")
                        .font(Font.Variant.body(weight: .bold).font)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(opacity))
                        .cornerRadius(15)
                }
            )
        } else {
            return AnyView(content)
        }
    }
}
