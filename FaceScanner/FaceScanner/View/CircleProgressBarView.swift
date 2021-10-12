//
//  CircleProgressBarView.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/8.
//

import UIKit

protocol CircleProgressBarViewDelegate: AnyObject {
    func circleProgressBarView(_ view: CircleProgressBarView, animationFinished: Void)
}

// MARK: -
class CircleProgressBarView: UIView {

    weak var delegate: CircleProgressBarViewDelegate?

    private let circleLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let startPoint = CGFloat(-Double.pi / 2)
    private let endPoint = CGFloat(3 * Double.pi / 2)

    private var circularProgressAnimation: CABasicAnimation?

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        createCircularPath()
    }

    func progressAnimation(duration: TimeInterval) {
        circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation!.duration = duration
        circularProgressAnimation!.toValue = 1.0
        circularProgressAnimation!.fillMode = .forwards
        circularProgressAnimation!.delegate = self
        progressLayer.add(circularProgressAnimation!, forKey: "progressAnimation")
    }
}

private extension CircleProgressBarView {

    func createCircularPath() {
        // created circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0,
                                                           y: frame.size.height / 2.0),
                                        radius: frame.size.width / 2,
                                        startAngle: startPoint,
                                        endAngle: endPoint,
                                        clockwise: true)

        // circleLayer
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 2
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
        layer.addSublayer(circleLayer)

        // progressLayer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 2
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor(named: "myYellow")?.cgColor
        layer.addSublayer(progressLayer)
    }

}

// MARK: -
extension CircleProgressBarView: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.delegate?.circleProgressBarView(self, animationFinished: ())
        }
    }
}
