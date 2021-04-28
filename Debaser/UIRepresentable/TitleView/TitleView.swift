//
//  TitleView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-19.
//

import SwiftUI

struct TitleView: UIViewRepresentable {
    typealias UIViewType = UILabel
    
    var title: String
    
    var innnerPadding: CGFloat = 25
    var outerPadding: CGFloat = 25
    var fontSize: CGFloat = 49
    var lineLimit: Int = 0
    var textColor: UIColor = .label

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let view = TitleLabel(title: title, fontSize: fontSize, lineLimit: lineLimit, textColor: textColor)

        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.preferredMaxLayoutWidth = UIScreen.main.bounds.width - ((innnerPadding + outerPadding) * 2)
    }
    
    class Coordinator: NSObject {
        var parent: TitleView
        
        init(_ view: TitleView) {
            parent = view
        }
    }
}

