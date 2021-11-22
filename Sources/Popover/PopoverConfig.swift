import UIKit

public struct PopoverConfig {
    public static var defaultBackgroundColor: UIColor = .tertiarySystemBackground
    public static var defaultBackgroundOverlayColor: UIColor = .black.withAlphaComponent(0.15)
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
    public struct PopoverPositioning {
        public var spacing: CGSize = .zero
        public var horizontalAlignment: PopoverAlignment = .center
        public var verticalAlignment: PopoverAlignment = .before
        public init() {}
    }
    public var container: UIView
    public var duration: TimeInterval = .infinity
    public var identifier: String? = nil
    public var insets: UIEdgeInsets = .zero

    public var backgroundColor: UIColor = PopoverConfig.defaultBackgroundColor
    public var backgroundOverlayColor: UIColor = PopoverConfig.defaultBackgroundOverlayColor
    public var cornerRadius: CGFloat = PopoverConfig.defaultCornerRadius
    public var shadowColor: UIColor = PopoverConfig.defaultShadowColor
    public var shadowOpacity: CGFloat = PopoverConfig.defaultShadowOpacity
    public var shadowRadius: CGFloat = PopoverConfig.defaultShadowRadius
    public var shadowOffset: CGSize = PopoverConfig.defaultShadowOffset

    public var dismissPreviousPopover: Bool = true
    public var showBackgroundOverlay: Bool = true
    public var dismissByBackgroundTap: Bool = true
    public var showTriangle: Bool = true

    public var anchor: PopoverAnchor = .frame(rect: CGRect(center: PopoverConfig.defaultContainer?.bounds.center ?? .zero, size: .zero))

    public var sourceRect: CGRect {
        get {
            switch anchor {
            case let .frame(rect):
                return rect
            case let .view(view):
                return container.convert(view.frameWithoutTransform, from: view.superview)
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
