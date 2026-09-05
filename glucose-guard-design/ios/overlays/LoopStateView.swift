//
//  LoopStateView.swift
//  LoopUI
//
//  Glucose Guard theme: brand mark inside the closed-loop status ring.
//  GLUCOSE_GUARD_THEME
//

import UIKit

final class LoopStateView: UIView {
    var firstDataUpdate = true

    private let markView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.image = UIImage(named: "glucose_guard_mark", in: Bundle(for: LoopStateView.self), compatibleWith: nil)
        return view
    }()

    override func tintColorDidChange() {
        super.tintColorDidChange()

        updateTintColor()
    }

    private func updateTintColor() {
        shapeLayer.strokeColor = tintColor.cgColor
    }

    var open = false {
        didSet {
            if open != oldValue {
                shapeLayer.path = drawPath()
            }
        }
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayer()
        embedMark()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayer()
        embedMark()
    }

    private func configureLayer() {
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        updateTintColor()
        shapeLayer.path = drawPath()
    }

    private func embedMark() {
        if markView.superview == nil {
            addSubview(markView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer.path = drawPath()
        let inset = max(8, shapeLayer.lineWidth + 3)
        markView.frame = bounds.insetBy(dx: inset, dy: inset)
        markView.layer.cornerRadius = markView.bounds.width * 0.22
    }

    private func drawPath(lineWidth: CGFloat? = nil) -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let lineWidth = lineWidth ?? shapeLayer.lineWidth
        let radius = min(bounds.width / 2, bounds.height / 2) - lineWidth / 2

        let startAngle = open ? -CGFloat.pi / 4 : 0
        let endAngle = open ? 5 * CGFloat.pi / 4 : 2 * CGFloat.pi

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        return path.cgPath
    }

    private static let AnimationKey = "com.loudnate.Naterade.breatheAnimation"

    var animated: Bool = false {
        didSet {
            if animated != oldValue {
                if animated {
                    let path = CABasicAnimation(keyPath: "path")
                    path.fromValue = shapeLayer.path ?? drawPath()
                    path.toValue = drawPath(lineWidth: 12)

                    let width = CABasicAnimation(keyPath: "lineWidth")
                    width.fromValue = shapeLayer.lineWidth
                    width.toValue = 8

                    let group = CAAnimationGroup()
                    group.animations = [path, width]
                    group.duration = firstDataUpdate ? 0 : 1
                    group.repeatCount = HUGE
                    group.autoreverses = true
                    group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                    shapeLayer.add(group, forKey: type(of: self).AnimationKey)
                } else {
                    shapeLayer.removeAnimation(forKey: type(of: self).AnimationKey)
                }
            }
            firstDataUpdate = false
        }
    }
}
