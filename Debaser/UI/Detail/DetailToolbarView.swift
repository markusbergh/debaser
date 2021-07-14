//
//  DetailToolbarView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-14.
//

import SwiftUI

struct DetailToolbarView: View {
    @EnvironmentObject var store: AppStore

    private var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.first(
            where: { $0.isKeyWindow }
        )?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
    }
    
    @Binding var isFavourite: Bool
    var event: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: statusBarHeight + 10)
            
            HStack {
                DetailBackButtonView(isStreaming: .constant(false))
                                
                Spacer()
                
                VStack {
                    Text(event.title)
                        .font(Font.Variant.body(weight: .regular).font)
                        .lineLimit(1)
                    
                    Text("Debaser Strand")
                        .font(Font.Variant.micro(weight: .bold).font)
                }

                Spacer()
                
                Button(action: {
                    withAnimation {
                        isFavourite.toggle()
                    }
                    
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    
                    store.dispatch(action: .list(.toggleFavourite(event)))
                }) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart" )
                        .resizable()
                        .frame(width: 30, height: 30)
                        .transition(
                            .asymmetric(
                                insertion: transition(insertionFor: isFavourite),
                                removal: transition(removalFor: isFavourite)
                            )
                        )
                        .id("is_favourite_\(isFavourite ? "active" : "inactive")_toolbar")
                }
                .foregroundColor(.red)
                .buttonStyle(PlainButtonStyle())

            }
            .frame(maxWidth: .infinity)

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 25)
        .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
        .background(Color.detailBackground.opacity(0.75))
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
        .ignoresSafeArea()
        .offset(y: -statusBarHeight)
    }
    
    private func transition(insertionFor favourite: Bool) -> AnyTransition {
        let duration: Double = 0.3
        let anim: Animation = .easeInOut(duration: duration)
        
        if !favourite {
            return .identity
        }

        return .scale(scale: 0).animation(anim).combined(
            with: .opacity.animation(anim)
        )
    }
    
    private func transition(removalFor favourite: Bool) -> AnyTransition {
        let duration: Double = 0.3
        let anim: Animation = .easeInOut(duration: duration)
        
        if !favourite {
            return .asymmetric(
                insertion: .opacity.animation(anim),
                removal: .opacity.animation(anim)
            )
        }
        
        return .scale.animation(anim)
    }
}

struct DetailToolbarView_Previews: PreviewProvider {
    
    static var previews: some View {
        let event = EventViewModel.mock

        DetailToolbarView(isFavourite: .constant(false), event: event)
    }
}
