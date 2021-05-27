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
    var fontSize: CGFloat = 49
    var lineLimit: Int = 0
    var textColor: UIColor = .label
    var width: CGFloat = UIScreen.main.bounds.width

    @Binding var calculatedHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let view = TitleLabel(title: title, fontSize: fontSize, lineLimit: lineLimit, textColor: textColor)
        
        setHeightIfNeeded(view)

        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = title
        
        setHeightIfNeeded(uiView)
    }
    
    private func setHeightIfNeeded(_ uiView: UILabel) {
        let fixedWidth = width
        
        // Needs to calculate a new size for frame
        let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        DispatchQueue.main.async {
            // Make sure we only update on the main thread
            self.calculatedHeight = newSize.height
        }
    }

    
    class Coordinator: NSObject {
        var parent: TitleView
        
        init(_ view: TitleView) {
            parent = view
        }
    }
}

