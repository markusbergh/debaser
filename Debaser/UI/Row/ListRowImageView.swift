//
//  ListRowImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-23.
//

import SwiftUI

struct ListRowImageView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private

    private var showImagesIfNeeded: Bool {
        return store.state.settings.showImages.value == true
    }
    
    // MARK: Public

    let imageURL: String
    let mediaHeight: CGFloat?

    var body: some View {
        if showImagesIfNeeded {
            AsyncImage(
                url: URL(string: imageURL),
                transaction: Transaction(animation: .easeOut(duration: 0.45))
            ) { phase in
                
                Group {
                    switch phase {
                    case .empty:
                        // TODO: Handle pending state
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity.combined(
                                with: .scale(scale: 0.8))
                            )
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        // Handle all other cases that might be added in the future
                        EmptyView()
                    }
                }
                .modifier(
                    ListRowImageSizeViewModifier(mediaHeight: mediaHeight)
                )
            }
            
        } else {
            Rectangle()
                .fill(Color.listRowBackground)
                .modifier(
                    ListRowImageSizeViewModifier(mediaHeight: mediaHeight)
                )
        }
    }
}

// MARK: - Size view modifier

struct ListRowImageSizeViewModifier: ViewModifier {
    
    let mediaHeight: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: mediaHeight)
            .cornerRadius(15)
    }
}

// MARK: - Status view modifier

struct ListRowImageStatusViewModifier: ViewModifier {
    @EnvironmentObject var store: AppStore
    
    // MARK: Public

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
