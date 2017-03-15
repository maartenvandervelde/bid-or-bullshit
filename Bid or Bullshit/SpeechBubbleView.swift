//
//  SpeechBubbleView.swift (adapted from https://github.com/sydneyitguy/SwiftSpeechBubble)
//  Bid or Bullshit
//
//  Created by M.A. van der Velde on 14/03/17.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class SpeechBubbleView: UIView {
    let strokeColor: UIColor = UIColor.black
    let fillColor: UIColor = UIColor.white
    var triangleHeight: CGFloat!
    var radius: CGFloat!
    var borderWidth: CGFloat!
    var edgeCurve: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(baseView: UIView, text: String, fontSize: CGFloat = 17) {
        // Calculate relative sizes
        let padding = fontSize * 0.7
        let triangleHeight = fontSize * 0.5
        let radius = fontSize * 1.2
        let borderWidth = fontSize * 0.25
        let margin = fontSize * 0.14 // margin between the baseview and balloon
        let edgeCurve = fontSize
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.text = text
        let labelSize = label.intrinsicContentSize
        
        let width = labelSize.width + padding * 3 // 50% more padding on width
        let height = labelSize.height + triangleHeight + padding * 2
        let bubbleRect = CGRect(x: baseView.center.x + (baseView.frame.size.width / 2) + margin, y: baseView.center.y - (height / 2), width: width, height: height)

        
        self.init(frame: bubbleRect)
        
        self.triangleHeight = triangleHeight
        self.radius = radius
        self.borderWidth = borderWidth
        self.edgeCurve = edgeCurve
        
        label.frame = CGRect(x: padding, y: padding, width: labelSize.width + padding, height: labelSize.height)
        label.textAlignment = .center
        label.textColor = strokeColor
        self.addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        let bubble = CGRect(x: 0, y: 0, width: rect.width - radius * 2, height: rect.height - (radius * 2 + triangleHeight)).offsetBy(dx: radius, dy: radius)
        let path = UIBezierPath()
        let radius2 = radius - borderWidth // Radius adjasted for the border width
        
        // Upper right corner
        path.addArc(withCenter: CGPoint(x: bubble.maxX, y: bubble.minY), radius: radius2, startAngle: CGFloat(-M_PI_2), endAngle: 0, clockwise: true)
        
        // Bottom right corner
        path.addArc(withCenter: CGPoint(x: bubble.maxX, y: bubble.maxY), radius: radius2, startAngle: 0, endAngle: CGFloat(M_PI_2), clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bubble.minX, y: bubble.maxY + radius2))
        
        // Pointy bit
        path.addLine(to: CGPoint(x: bubble.minX - 20, y: bubble.minY + (bubble.height / 2)))
        path.addLine(to: CGPoint(x: bubble.minX, y: bubble.minY - radius2))
    
        // Top edge
        path.close()
        
        fillColor.setFill()
        strokeColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
        path.fill()
    }
}
