//
//  ScrollViewOffset.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-14.
//

import SwiftUI

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        // Just store it
    }
}

struct ScrollView<Content: View>: View {
    let axis: Axis.Set
    let showsIndicators: Bool
    let offsetDidChange: (CGPoint) -> Void
    let content: Content

    init(
        axis: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetDidChange: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.offsetDidChange = offsetDidChange
        self.content = content()
    }
    
    var body: some View {
        SwiftUI.ScrollView(axis, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
            }.frame(width: 0, height: 0)
            
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetDidChange)
    }
}
