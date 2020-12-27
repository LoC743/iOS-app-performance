//
//  LoadingView.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 19.10.2020.
//

import UIKit

class LoadingView: UIView {
    
    var circles: [CAShapeLayer] = []
    
    var amountOfCircles: Int = 4

    override func draw(_ rect: CGRect) {
        setupView()
        createCircles()
        animate()
    }
    
    private func setupView() {
        let view = UIView(frame: self.frame)
        view.backgroundColor = .black
        view.alpha = 0.6
        self.addSubview(view)
    }
    
    private func createCircles(radius: CGFloat = 15) {
        let padding: Int = 5
        let circlesWidth: Int = amountOfCircles * Int(radius) * 2 + (amountOfCircles - 1) * padding

        var x: CGFloat = self.center.x - CGFloat(circlesWidth)/2 + radius // Start X
        let y: CGFloat = self.center.y + radius // Y
        
        for _ in 0..<amountOfCircles {
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = Colors.cornflowerBlue.cgColor
            shapeLayer.opacity = 1
            
            circles.append(shapeLayer)
            self.layer.addSublayer(shapeLayer)
            
            x += 5 + 2 * radius
        }
    }
    
    private func animate() {
        var delay: Double = 0
        let duration: Double = 0.35
        
        circles.forEach { (circle) in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = duration
            
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fillMode = .forwards
            animation.autoreverses = true
            animation.isRemovedOnCompletion = false
            
            let group = CAAnimationGroup()
            group.animations = [animation]
            group.beginTime = CACurrentMediaTime() + delay
            group.duration = duration * Double(amountOfCircles)
            group.repeatCount = .infinity
            
            circle.add(group, forKey: "loading")
            
            delay += duration
        }
    }

}
