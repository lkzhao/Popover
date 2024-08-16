import UIKit

public struct PopoverConfig {
    public static var defaultBackgroundColor: UIColor = .tertiarySystemBackground
    public static var defaultBackgroundOverlayColor: UIColor = .black.withAlphaComponent(0.15)
    public static var defaultBorderColor: UIColor = .separator
    public static var defaultBorderWidth: CGFloat = 0
    public static var defaultCornerRadius: CGFloat = 16.0
    public static var defaultShadowColor: UIColor = .black
    public static var defaultShadowOpacity: CGFloat = 0.3
    public static var defaultShadowRadius: CGFloat = 2
    public static var defaultShadowOffset: CGSize = CGSize(width: 0, height: 2)
    public static var defaultContainer: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })

    public enum PopoverAlignment {
        case before, start, center, end, after
    }
    public enum PopoverAnchor {
        case frame(rect: CGRect)
        case view(view: UIView)
    }
    public enum PopoverTransitionType {
        case tooltip, notification
    }
    public struct PopoverPositioning {
        public var spacing: CGSize = .zero
        public var horizontalAlignment: PopoverAlignment = .center
        public var verticalAlignment: PopoverAlignment = .before
        public init() {}
    }
    public var container: UIView
    public var duration: TimeInterval = .infinity
    public var delay: TimeInterval = 0
    public var identifier: String? = nil
    public var insets: UIEdgeInsets = .zero
    public var containerInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    public var transitionType: PopoverTransitionType = .tooltip
    public var appearingAnimationDuration: CGFloat = 0.4
    public var appearingAnimationSpringDamping: CGFloat = 0.8
    public var appearingAnimationInitialSpringVelocity: CGFloat = 0.0
    public var disappearingAnimationDuration: CGFloat = 0.28

    public var backgroundColor: UIColor = PopoverConfig.defaultBackgroundColor
    public var backgroundOverlayColor: UIColor = PopoverConfig.defaultBackgroundOverlayColor
    public var cornerRadius: CGFloat = PopoverConfig.defaultCornerRadius
    public var borderColor: UIColor = PopoverConfig.defaultBorderColor
    public var borderWidth: CGFloat = PopoverConfig.defaultBorderWidth
    public var shadowColor: UIColor = PopoverConfig.defaultShadowColor
    public var shadowOpacity: CGFloat = PopoverConfig.defaultShadowOpacity
    public var shadowRadius: CGFloat = PopoverConfig.defaultShadowRadius
    public var shadowOffset: CGSize = PopoverConfig.defaultShadowOffset
    public var triangleColor: UIColor? = nil

    public var clipsToBounds: Bool = true
    public var dismissPreviousPopover: Bool = true
    public var showBackgroundOverlay: Bool = true
    public var dismissByBackgroundTap: Bool = true
    public var shouldBlockBackgroundTapGesture: Bool = true
    public var showTriangle: Bool = true
    public var ignoreAnchorViewTransform: Bool = false

    public var anchor: PopoverAnchor = .frame(rect: CGRect(center: PopoverConfig.defaultContainer?.bounds.center ?? .zero, size: .zero))
    
    // block to be call when background tap is detected. return true if you want to dismiss the popover
    public var onBackgroundTap: ((UIGestureRecognizer) -> Bool)?

    public var onDismiss: (() -> Void)?

    public var sourceRect: CGRect {
        get {
            switch anchor {
            case let .frame(rect):
                return rect
            case let .view(view):
                if ignoreAnchorViewTransform {
                    return container.convert(view.frameWithoutTransform, from: view.superview)
                } else {
                    return container.convert(view.bounds, from: view)
                }
            }
        }
        set {
            anchor = .frame(rect: newValue)
        }
    }

    public var positioning = PopoverPositioning()
    public var transformPositioning: PopoverPositioning?

    public init(container: UIView) {
        self.container = container
    }
}
