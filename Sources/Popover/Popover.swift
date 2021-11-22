import Foundation
import UIKit
import BaseToolbox

internal class ShapeView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    var path: UIBezierPath? {
        didSet {
            shapeLayer.path = path?.cgPath
        }
    }

    var fillColor: UIColor? {
        didSet {
            shapeLayer.fillColor = fillColor?.cgColor
        }
    }

    var strokeColor: UIColor? {
        didSet {
            shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            shapeLayer.fillColor = fillColor?.cgColor
            shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }
}

public class PopoverView: UIView {
    public var identifier: String?
    public var insets = UIEdgeInsets.zero

    let triangle = ShapeView()

    let contentWrapperView = UIView().then {
        $0.cornerRadius = 12
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }

    public internal(set) var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView = contentView {
                contentWrapperView.addSubview(contentView)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        contentWrapperView.cornerRadius = 12
        contentWrapperView.backgroundColor = .white
        triangle.fillColor = .white
        triangle.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 4)
        triangle.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)

        let radius: CGFloat = 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 10))
        path.addLine(to: CGPoint(x: 20, y: 20 - radius))
        path.addArc(
            withCenter: CGPoint(x: 20 - radius, y: 20 - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2,
            clockwise: true)
        path.addLine(to: CGPoint(x: 10, y: 20))
        path.addArc(
            withCenter: CGPoint(x: 10, y: 10), radius: 10, startAngle: CGFloat.pi / 2, endAngle: 2 * CGFloat.pi,
            clockwise: true)
        triangle.path = path
        addSubview(triangle)
        addSubview(contentWrapperView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public override func layoutSubviews() {
        super.layoutSubviews()
        contentWrapperView.frame = bounds
        contentView?.frame = bounds.inset(by: insets)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentView?.sizeThatFits(size) ?? .zero
    }
}
