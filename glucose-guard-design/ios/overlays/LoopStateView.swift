//
//  LoopStateView.swift
//  LoopUI
//
//  Glucose Guard: Loop’s status ring stays, but it is a full circle around
//  the brand mark — never the chopped C-gap. Green when the loop is fresh.
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
        shapeLayer.shadowColor = tintColor.cgColor
        shapeLayer.shadowOpacity = 0.55
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowOffset = .zero
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
        clipsToBounds = false
        shapeLayer.lineWidth = 4.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeEnd = 1
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
        let inset = shapeLayer.lineWidth + 5
        markView.frame = bounds.insetBy(dx: inset, dy: inset)
        markView.layer.cornerRadius = min(markView.bounds.width, markView.bounds.height) / 2
    }

    private func drawPath(lineWidth: CGFloat? = nil) -> CGPath {
        let stroke = lineWidth ?? shapeLayer.lineWidth
        let inset = stroke / 2 + 0.5
        let rect = bounds.insetBy(dx: inset, dy: inset)
        return UIBezierPath(ovalIn: rect).cgPath
    }

    private static let AnimationKey = "com.loudnate.Naterade.breatheAnimation"

    var animated: Bool = false {
        didSet {
            if animated != oldValue {
                if animated {
                    let path = CABasicAnimation(keyPath: "path")
                    path.fromValue = shapeLayer.path ?? drawPath()
                    path.toValue = drawPath(lineWidth: 7)

                    let width = CABasicAnimation(keyPath: "lineWidth")
                    width.fromValue = shapeLayer.lineWidth
                    width.toValue = 6

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
