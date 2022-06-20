import UIKit

final internal class FSPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    var transitionStyle: FSPopupDialogTransitionStyle
    var interactor: FSInteractiveTransition
    var backgroundColor: UIColor?
    var blur: UIBlurEffect?

    init(transitionStyle: FSPopupDialogTransitionStyle, interactor: FSInteractiveTransition, backgroundColor: UIColor?, blur: UIBlurEffect?) {
        self.transitionStyle = transitionStyle
        self.interactor = interactor
        self.backgroundColor = backgroundColor
        self.blur = blur
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: source, backgroundColor: backgroundColor, blur: blur)
        return presentationController
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .presenting)
        case .bounceDown:
            transition = BounceDownTransition(direction: .presenting)
        case .zoomIn:
            transition = ZoomTransition(direction: .presenting)
        case .fadeIn:
            transition = FadeTransition(direction: .presenting)
        }

        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if interactor.hasStarted || interactor.shouldFinish {
            return DismissInteractiveTransition()
        }

        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .dismissing)
        case .bounceDown:
            transition = BounceDownTransition(direction: .dismissing)
        case .zoomIn:
            transition = ZoomTransition(direction: .dismissing)
        case .fadeIn:
            transition = FadeTransition(direction: .dismissing)
        }

        return transition
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

final internal class PresentationController: UIPresentationController {

    private let overlay: PopupOverlayView
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, backgroundColor: UIColor?, blur: UIBlurEffect?) {
        overlay = PopupOverlayView(backgroundColor: backgroundColor, blur: blur)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else { return }
        
        overlay.frame = containerView.bounds
        containerView.insertSubview(overlay, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlay.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlay.alpha = 0.0
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        guard let presentedView = presentedView else { return }
        presentedView.frame = frameOfPresentedViewInContainerView
    }

}
