import UIKit

/// a gesture that notifies the target whenever a touch begans. It doesn't block touch or any other gestures
public class PopoverDismissGesture: UIGestureRecognizer {
    var startPosition: CGPoint?
    var blockTap: Bool = true

    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        if #available(iOS 13.4, *) {
            allowedTouchTypes = [
                NSNumber(value: UITouch.TouchType.pencil.rawValue),
                NSNumber(value: UITouch.TouchType.direct.rawValue),
                NSNumber(value: UITouch.TouchType.indirect.rawValue),
                NSNumber(value: UITouch.TouchType.indirectPointer.rawValue),
            ]
        } else {
            allowedTouchTypes = [
                NSNumber(value: UITouch.TouchType.pencil.rawValue),
                NSNumber(value: UITouch.TouchType.direct.rawValue),
                NSNumber(value: UITouch.TouchType.indirect.rawValue),
            ]
        }
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        cancelsTouchesInView = false
        delegate = self
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        startPosition = touches.first?.location(in: nil)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if let startPosition = startPosition, let currentPosition = touches.first?.location(in: nil), currentPosition.distance(startPosition) >= 10 {
            state = .recognized
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if state == .possible {
            state = .recognized
        }
    }
}

extension PopoverDismissGesture: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // we block tap gesture underneath the popover view
        if blockTap, otherGestureRecognizer is UITapGestureRecognizer ||
            "\(type(of: otherGestureRecognizer))" == "_UITouchDownGestureRecognizer" // this gesture is used for UIButton with menu
        {
            return otherGestureRecognizer.view?.closestViewMatchingType(PopoverView.self) == nil
        } else {
            return false
        }
    }
}
