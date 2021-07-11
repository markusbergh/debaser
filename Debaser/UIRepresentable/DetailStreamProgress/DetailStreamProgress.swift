//
//  DetailStreamProgress.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-26.
//

import SwiftUI
import UIKit

struct DetailStreamProgress: UIViewRepresentable {
    let streamProgress: CGFloat
    var strokeColor: CGColor = UIColor.green.cgColor
    var lineWidth: CGFloat = 2.5
    
    func makeUIView(context: Context) -> UIView {
        let progressView = DBSRUIStreamProgress(using: strokeColor, lineWidth: lineWidth)
        
        return progressView
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        if let view = view as? DBSRUIStreamProgress {
            guard streamProgress > 0 else {
                guard let subLayers = view.layer.sublayers else { return }
                
                for layer in subLayers {
                    layer.removeFromSuperlayer()
                }
                
                return
            }
            
            // Update the progress
            view.percentage = streamProgress
            
            // Redraw the view
            view.setNeedsDisplay()
        }
    }
}

class DBSRUIStreamProgress: UIView {
    var strokeColor: CGColor
    var lineWidth: CGFloat
    var percentage: CGFloat?
    var startAngle: CGFloat?
    var endAngle: CGFloat?

    override init(frame: CGRect) {
        strokeColor = UIColor.green.cgColor
        lineWidth = 2.5
        
        super.init(frame: frame)
        
        startAngle = CGFloat(Double.pi * 1.5)
        endAngle = CGFloat((Double.pi * 2)) + startAngle!
        percentage = 0.0
    }
    
    convenience init(using strokeColor: CGColor, lineWidth: CGFloat) {
        self.init()
        
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        
        if let startAngle = self.startAngle, let endAngle = self.endAngle, let percentage = self.percentage {
            let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
            let radius =  CGFloat(floorf(Float(frame.size.width / 2)) - 2.5)
            
            bezierPath.addArc(withCenter: center,
                              radius: radius,
                              startAngle: startAngle,
                              endAngle: endAngle,
                              clockwise: true)
            
            let shapeView = CAShapeLayer()
            shapeView.path = bezierPath.cgPath
            shapeView.fillColor = nil
            shapeView.strokeColor = strokeColor
            shapeView.lineWidth = lineWidth
            shapeView.strokeEnd = percentage
            
            layer.addSublayer(shapeView)
        }
    }
    
    private func animateChange() {

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
