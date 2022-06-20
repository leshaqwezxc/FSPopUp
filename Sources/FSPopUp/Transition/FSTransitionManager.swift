import UIKit

final internal class FSInteractiveTransition: UIPercentDrivenInteractiveTransition {

    var hasStarted = false
    var shouldFinish = false

    weak var viewController: UIViewController?

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {

        guard let vc = viewController else { return }

        guard let progress = calculateProgress(sender: sender) else { return }

        switch sender.state {
        case .began:
            hasStarted = true
            vc.dismiss(animated: true, completion: nil)
        case .changed:
            shouldFinish = progress > 0.3
            update(progress)
        case .cancelled:
            hasStarted = false
            cancel()
        case .ended:
            hasStarted = false
            completionSpeed = 0.55
            shouldFinish ? finish() : cancel()
        default:
            break
        }
    }
}

extension FSInteractiveTransition {
    
    func calculateProgress(sender: UIPanGestureRecognizer) -> CGFloat? {
        guard let vc = viewController else { return nil }

        let translation = sender.translation(in: vc.view)
        let verticalMovement = translation.y / vc.view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        return progress
    }
}
