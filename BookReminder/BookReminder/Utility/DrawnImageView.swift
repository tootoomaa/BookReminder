//
//  DrawnImageView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/19.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

// https://stackoverflow.com/a/41009006/4488252
class DrawnImageView: UIImageView {
    private lazy var path = UIBezierPath()
    private lazy var previousTouchPoint = CGPoint.zero
    private lazy var shapeLayer = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupView(){
        layer.addSublayer(shapeLayer)
        shapeLayer.lineWidth = 4
        shapeLayer.strokeColor = UIColor.white.cgColor
        isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let location = touches.first?.location(in: self) { previousTouchPoint = location }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let location = touches.first?.location(in: self) {
            path.move(to: location)
            path.addLine(to: previousTouchPoint)
            previousTouchPoint = location
            shapeLayer.path = path.cgPath
        }
    }
}

// https://stackoverflow.com/a/40953026/4488252
extension UIView {
    var screenShot: UIImage?  {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
