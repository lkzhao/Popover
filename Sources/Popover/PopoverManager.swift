import UIKit
import BaseToolbox
import KeyboardManager

struct PopoverData {
    let view: PopoverView
    let backgroundView: UIView?
    let gesture: PopoverDismissGesture?
    var config: PopoverConfig
}

public class PopoverManager: NSObject {
    public static let shared = PopoverManager()

    private var popovers: [PopoverData] = []
    public var currentPopover: PopoverView? {
        return popovers.last?.view
    }
    public var currentPopoverConfig: PopoverConfig? {
        get {
            popovers.last?.config
        }
        set {
            if let newValue = newValue, !popovers.isEmpty {
                popovers[popovers.count - 1].config = newValue
            }
        }
    }
    public var currentBackgroundOverlay: UIView? {
        return popovers.last?.backgroundView
    }
    var hideTimer: Timer?

    // block to be call when background tap is detected. return true if you want to dismiss the popover
    public var onBackgroundTap: ((UIGestureRecognizer) -> Bool)?

    public var onDismiss: (() -> Void)?

    public func show(
        popover: UIView,
        at: UIView,
        space: CGFloat = 10,
        showOnTop: Bool? = nil,
        showBackgroundOverlay: Bool = true,
        showTriangle: Bool = true,
        container: UIView? = nil
    ) {
        guard let container = container ?? at.window else { return }
        let maxSize = UIScreen.main.bounds.size.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        let size = popover.sizeThatFits(maxSize)
        let shouldShowOnTop = container.convert(.zero, from: at).y > container.safeAreaInsets.top + 5 + size.height + space
        let showOnTop = showOnTop ?? shouldShowOnTop
        let position = CGPoint(x: at.bounds.midX, y: showOnTop ? -space : at.bounds.maxY + space)
        show(
            popover: popover,
            container: container,
            position: container.convert(position, from: at),
            showOnTop: showOnTop,
            showBackgroundOverlay: showBackgroundOverlay,
            showTriangle: showTriangle)
    }

    public func show(
        popover: UIView,
        duration: TimeInterval = .infinity,
        identifier: String? = nil,
        insets: UIEdgeInsets = .zero,
        backgroundColor: UIColor = PopoverConfig.defaultBackgroundColor,
        cornerRadius: CGFloat = PopoverConfig.defaultCornerRadius,
        container: UIView = PopoverConfig.defaultContainer!,
        position: CGPoint = PopoverConfig.defaultContainer!.bounds.center,
        showOnTop: Bool = true,
        showBackgroundOverlay: Bool = true,
        dismissByBackgroundTap: Bool = true,
        alignLeft: Bool = false,
        showTriangle: Bool = true
    ) {
        var config = PopoverConfig(container: container)
        config.duration = duration
        config.identifier = identifier
        config.insets = insets
        config.backgroundColor = backgroundColor
        config.cornerRadius = cornerRadius
        config.container = container
        config.showBackgroundOverlay = showBackgroundOverlay
        config.dismissByBackgroundTap = dismissByBackgroundTap
        config.showTriangle = showTriangle
        config.positioning.verticalAlignment = showOnTop ? .before : .after
        config.positioning.horizontalAlignment = alignLeft ? .start : .center
        config.sourceRect = CGRect(center: position, size: .zero)
        show(popover: popover, config: config)
    }

    @objc func didTouch(gr: PopoverDismissGesture) {
        if let currentPopover = PopoverManager.shared.currentPopover,
           currentPopover.hitTest(gr.location(in: currentPopover), with: nil) == nil,
           PopoverManager.shared.popovers.last?.config.dismissByBackgroundTap ?? true,
           PopoverManager.shared.onBackgroundTap?(gr) ?? true
        {
            let id = PopoverManager.shared.currentPopover?.identifier
            delay(0.1) {
                if PopoverManager.shared.currentPopover?.identifier == id {
                    PopoverManager.shared.dismiss()
                }
            }
        }
    }

    public func show(popover: UIView, config: PopoverConfig) {
        if let oldIdentifier = currentPopover?.identifier, oldIdentifier == config.identifier {
            // skip if identifier matches
            return
        }

        let container = config.container

        if config.dismissPreviousPopover {
            dismiss()
        }

        let popoverWrapper = PopoverView()
        popoverWrapper.identifier = config.identifier ?? UUID().uuidString
        popoverWrapper.contentWrapperView.cornerRadius = config.cornerRadius
        popoverWrapper.insets = config.insets
        popoverWrapper.contentView = popover
        popoverWrapper.zPosition = 10
        popoverWrapper.contentWrapperView.backgroundColor = config.backgroundColor
        popoverWrapper.triangle.fillColor = config.backgroundColor
        popoverWrapper.shadowRadius = config.shadowRadius
        popoverWrapper.shadowOpacity = config.shadowOpacity
        popoverWrapper.shadowColor = config.shadowColor
        popoverWrapper.shadowOffset = config.shadowOffset
        popoverWrapper.transform = self.layout(popover: popoverWrapper, config: config)

        var backgroundOverlay: UIView? = nil
        if config.showBackgroundOverlay {
            backgroundOverlay = UIView().then {
                $0.backgroundColor = config.backgroundOverlayColor
            }
        }

        let gesture = PopoverDismissGesture(target: self, action: #selector(didTouch))
        if config.dismissByBackgroundTap {
            container.addGestureRecognizer(gesture)
        }

        if !config.showTriangle {
            popoverWrapper.triangle.isHidden = true
        }
        if let backgroundOverlay = backgroundOverlay {
            backgroundOverlay.zPosition = 10
            backgroundOverlay.frame = container.bounds
            backgroundOverlay.alpha = 0
            container.addSubview(backgroundOverlay)
        }
        container.addSubview(popoverWrapper)
        popovers.append(PopoverData(view: popoverWrapper, backgroundView: backgroundOverlay, gesture: gesture, config: config))
        popoverWrapper.alpha = 0
        UIView.animate(
            withDuration: 0.48, delay: 0,
            usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                backgroundOverlay?.alpha = 1
                popoverWrapper.transform = .identity
                popoverWrapper.alpha = 1
            })

        hideTimer?.invalidate()
        if config.duration != .infinity {
            hideTimer = Timer.scheduledTimer(
                timeInterval: config.duration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
        }
    }

    func origin(positioning: PopoverConfig.PopoverPositioning, sourceRect: CGRect, size: CGSize, containerRect: CGRect)
    -> CGPoint
    {
        let spacing = positioning.spacing
        var popoverOrigin = CGPoint.zero
        switch positioning.horizontalAlignment {
        case .before:
            popoverOrigin.x = sourceRect.minX - size.width - spacing.width
        case .start:
            popoverOrigin.x = sourceRect.minX + spacing.width
        case .center:
            popoverOrigin.x = sourceRect.midX - size.width / 2
        case .end:
            popoverOrigin.x = sourceRect.maxX - size.width - spacing.width
        case .after:
            popoverOrigin.x = sourceRect.maxX + spacing.width
        }
        switch positioning.verticalAlignment {
        case .before:
            popoverOrigin.y = sourceRect.minY - size.height - spacing.height
        case .start:
            popoverOrigin.y = sourceRect.minY + spacing.height
        case .center:
            popoverOrigin.y = sourceRect.midY - size.height / 2
        case .end:
            popoverOrigin.y = sourceRect.maxY - size.height - spacing.height
        case .after:
            popoverOrigin.y = sourceRect.maxY + spacing.height
        }
        popoverOrigin.x = popoverOrigin.x.clamp(containerRect.minX, containerRect.maxX - size.width)
        popoverOrigin.y = popoverOrigin.y.clamp(containerRect.minY, containerRect.maxY - size.height)
        return popoverOrigin
    }

    func layout(popover: PopoverView, config: PopoverConfig) -> CGAffineTransform {
        let container = config.container
        let sourceRect = config.sourceRect
        let containerRect = container.bounds.inset(by: config.containerInsets).inset(
            by: UIEdgeInsets(
                top: container.safeAreaInsets.top, left: container.safeAreaInsets.left,
                bottom: max(container.safeAreaInsets.bottom, KeyboardManager.shared.keyboardHeight), right: container.safeAreaInsets.right))
        var size = popover.sizeThatFits(containerRect.size.inset(by: config.insets)).inset(by: -config.insets)
        size.height = min(containerRect.height, size.height)
        size.width = min(containerRect.width, size.width)

        popover.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        popover.layoutSubviews()
        
        let popoverOrigin = origin(
            positioning: config.positioning, sourceRect: sourceRect, size: size, containerRect: containerRect)
        let transformOrigin = origin(
            positioning: config.transformPositioning ?? config.positioning, sourceRect: config.sourceRect, size: .zero,
            containerRect: containerRect)
        let localTransformOrigin = transformOrigin - popoverOrigin
        popover.layer.anchorPoint = .zero
        popover.layer.position = popoverOrigin
        if config.positioning.verticalAlignment == .start || config.positioning.verticalAlignment == .after {
            popover.triangle.center = localTransformOrigin + CGPoint(x: 0, y: 8)
            popover.triangle.transform = CGAffineTransform.identity.scaledBy(x: 1, y: -1).rotated(by: CGFloat.pi / 4)
        } else {
            popover.triangle.center = localTransformOrigin + CGPoint(x: 0, y: -8)
        }

        // return: Entry Transform
        return CGAffineTransform.identity.translatedBy(x: localTransformOrigin.x, y: localTransformOrigin.y)
            .scaledBy(x: 0.1, y: 0.1).translatedBy(x: -localTransformOrigin.x, y: -localTransformOrigin.y)
    }

    public func relayout() {
        for popoverData in popovers {
            _ = layout(popover: popoverData.view, config: popoverData.config)
        }
    }

    @objc public func dismiss() {
        hide(completion: nil)
    }

    public func hide(completion: (() -> Void)?) {
        let onDismiss = self.onDismiss
        hideTimer?.invalidate()
        onBackgroundTap = nil
        self.onDismiss = nil
        if let popoverData = popovers.popLast() {
            let entryTransform = self.layout(popover: popoverData.view, config: popoverData.config)
            if let gesture = popoverData.gesture {
                gesture.view?.removeGestureRecognizer(gesture)
            }
            UIView.animate(
                withDuration: 0.28, delay: 0, options: [.beginFromCurrentState],
                animations: {
                    popoverData.view.transform = entryTransform
                    popoverData.view.alpha = 0
                    popoverData.backgroundView?.alpha = 0
                }
            ) { _ in
                completion?()
                popoverData.backgroundView?.removeFromSuperview()
                popoverData.view.removeFromSuperview()
            }
        } else {
            completion?()
        }
        onDismiss?()
    }
}
