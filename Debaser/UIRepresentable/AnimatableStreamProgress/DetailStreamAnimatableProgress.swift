//
//  DetailStreamAnimatableProgress.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-26.
//

import SwiftUI
import UIKit

struct DetailStreamAnimatableProgress: UIViewRepresentable {
    let width: CGFloat
    let height: CGFloat
    let streamProgress: CGFloat
    var lineWidth: CGFloat = 2.5
    var strokeColor: CGColor = UIColor.green.cgColor

    func makeUIView(context: Context) -> UIView {
        let progressView = DBSRUIStreamAnimatableProgress(
            width: width,
            height: height,
            using: strokeColor,
            lineWidth: lineWidth
        )
        
        return progressView
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        if let view = view as? DBSRUIStreamProgress {
            // Update the progress
            view.percentage = streamProgress
        }
    }
}
