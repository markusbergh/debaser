//
//  DetailStreamProgressAnimatableView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-11.
//

import UIKit

class DBSRUIStreamAnimatableProgress: UIView {

    private var circleLayer: CAShapeLayer?

    var width: CGFloat
    var height: CGFloat
    var strokeColor: CGColor
    var lineWidth: CGFloat
    var percentage: CGFloat {
        didSet {
            animateChange(withEnd: percentage)
        }
    }

    override init(frame: CGRect) {
        strokeColor = UIColor.green.cgColor
        lineWidth = 2.5
        percentage = 0.0
        width = 0.0
        height = 0.0

        super.init(frame: frame)
    }
    
    convenience init(width: CGFloat, height: CGFloat, using strokeColor: CGColor, lineWidth: CGFloat) {
        self.init()
        
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.width = width
        self.height = height
        
        drawCircle()
    }
    
    private func drawCircle() {
        let startAngle = CGFloat(Double.pi * 1.5)
        let endAngle = CGFloat((Double.pi * 2)) + startAngle
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let radius = CGFloat(floorf(Float(width / 2)) - 2.5)

        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
        
        circleLayer = CAShapeLayer()
        circleLayer?.path = circlePath.cgPath
        circleLayer?.fillColor = nil
        circleLayer?.strokeColor = strokeColor
        circleLayer?.lineWidth = lineWidth
        circleLayer?.strokeEnd = 0.0
        
        if let circleLayer = circleLayer {
            layer.addSublayer(circleLayer)
        }
    }
        
    func animateChange(duration: TimeInterval = 0.5, withEnd strokeEnd: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        animation.fromValue = circleLayer?.strokeEnd
        animation.toValue = strokeEnd
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        if let circleLayer = circleLayer {
            circleLayer.strokeEnd = strokeEnd
            circleLayer.add(animation, forKey: "circleAnimation")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
