import UIKit

final public class FSPopupOverlayView: UIView {

    // MARK: - Views

    private lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(frame: .zero)
        blurView.tintColor = .clear
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return blurView
    }()

    private lazy var overlay: UIView = {
        let overlay = UIView(frame: .zero)
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return overlay
    }()

    // MARK: - Inititalisers
    
    init(backgroundColor: UIColor?, blur: UIBlurEffect?) {
        super.init(frame: .zero)
        overlay.backgroundColor = backgroundColor
        blurView.effect = blur
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    private func setupView() {
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundColor = .clear
        alpha = 0
        addSubview(blurView)
        addSubview(overlay)
    }
}
