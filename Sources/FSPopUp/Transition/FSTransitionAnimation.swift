import Foundation
import UIKit

class FSTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var to: UIViewController!
    var from: UIViewController!
    let inDuration: TimeInterval
    let outDuration: TimeInterval
    let direction: FSAnimationDirection

    init(inDuration: TimeInterval, outDuration: TimeInterval, direction: AnimationDirection) {
        self.inDuration = inDuration
        self.outDuration = outDuration
        self.direction = direction
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .presenting ? inDuration : outDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .presenting:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from

            let container = transitionContext.containerView
            container.addSubview(to.view)
        case .dismissing:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from
        }
    }
}

public enum FSPopUpTransitionStyle: Int {
    case bounceUp
    case bounceDown
    case zoomIn
    case fadeIn
}

final internal class BounceUpTransition: TransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .presenting:
            to.view.bounds.origin = CGPoint(x: 0, y: -from.view.bounds.size.height)
            UIView.animate(withDuration: inDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.to.view.bounds = self.from.view.bounds
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .dismissing:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.bounds.origin = CGPoint(x: 0, y: -self.from.view.bounds.size.height)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

final internal class BounceDownTransition: TransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .presenting:
            to.view.bounds.origin = CGPoint(x: 0, y: from.view.bounds.size.height)
            UIView.animate(withDuration: inDuration, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.to.view.bounds = self.from.view.bounds
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .dismissing:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.bounds.origin = CGPoint(x: 0, y: self.from.view.bounds.size.height)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

final internal class ZoomTransition: TransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .presenting:
            to.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: inDuration, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.to.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .dismissing:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

final internal class FadeTransition: TransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .presenting:
            to.view.alpha = 0
            UIView.animate(withDuration: inDuration, delay: 0.0, options: [.curveEaseOut],
            animations: { [weak self] in
                guard let self = self else { return }
                self.to.view.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .dismissing:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

/// Used for the always drop out animation with pan gesture dismissal
final internal class DismissInteractiveTransition: TransitionAnimator {

    init() {
        super.init(inDuration: 0.22, outDuration: 0.32, direction: .dismissing)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        UIView.animate(withDuration: outDuration, delay: 0.0, options: [.beginFromCurrentState], animations: { [weak self] in
            guard let self = self else { return }
            self.from.view.bounds.origin = CGPoint(x: 0, y: -self.from.view.bounds.size.height)
            self.from.view.alpha = 0.0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
