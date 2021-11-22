import UIKit

/// a gesture that notifies the target whenever a touch begans. It doesn't block touch or any other gestures
internal class TouchObserveGesture: UIGestureRecognizer {

  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    delaysTouchesBegan = false
    delaysTouchesEnded = false
    cancelsTouchesInView = false
    delegate = self
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    state = .began
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    if state == .began {
      state = .changed
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
    if state == .began || state == .changed {
      state = .ended
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
    if state == .began || state == .changed {
      state = .cancelled
    }
  }
}

extension TouchObserveGesture: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return false
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return false
  }
}
