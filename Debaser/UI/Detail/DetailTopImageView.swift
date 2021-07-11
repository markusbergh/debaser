//
//  DetailTopImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import SwiftUI

struct DetailTopImageView: View {
    @EnvironmentObject var imageViewModel: ImageViewModel
    
    private let imageHeight: CGFloat = 275
    
    var body: some View {
        GeometryReader { geometry -> DetailImageView in
            var width =  geometry.size.width
            var height = geometry.size.height + geometry.frame(in: .global).minY
            var offsetY = -geometry.frame(in: .global).minY
            
            if geometry.frame(in: .global).minY <= 0 {
                width = geometry.size.width
                height = geometry.size.height
                offsetY = -geometry.frame(in: .global).minY / 3
            }
            
            return DetailImageView(
                image: imageViewModel.image,
                isLoaded: imageViewModel.isLoaded,
                width: width,
                height: height,
                offset: offsetY
            )
        }
        .frame(height: imageHeight)
    }
}

struct DetailImageView: View {
    let image: UIImage
    let isLoaded: Bool
    let width: CGFloat
    let height: CGFloat
    let offset: CGFloat
        
    private var offsetY: CGFloat {
        return isLoaded ? offset : 0.0
    }
        
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .animation(nil, value: isLoaded)
            .modifier(DetailImageAnimationModifier(isLoaded: isLoaded))
            .mask(DetailImageMaskView())
            .offset(y: offsetY)
            .animation(nil, value: isLoaded)
    }
}

struct DetailImageAnimationModifier: ViewModifier {
    let isLoaded: Bool
    
    private var scaleEffect: CGFloat {
        return isLoaded ? 1.0 : 1.25
    }
    
    private var opacity: Double {
        return isLoaded ? 1.0 : 0.0
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleEffect)
            .opacity(opacity)
            .animation(.easeOut(duration: 0.5), value: isLoaded)
    }
}

struct DetailImageMaskView: View {
    private let radius: CGFloat = 50.0
    private let corners: UIRectCorner = [.bottomLeft, .bottomRight]
    
    var body: some View {
        Rectangle()
            .cornerRadius(radius, corners: corners)
    }
}

struct DetailImageView_Previews: PreviewProvider {
    static let image = UIImage(named: "EventImage")!
    
    static var previews: some View {
        DetailImageView(
            image: image,
            isLoaded: true,
            width: 390,
            height: 250,
            offset: 0
        )
    }
}
