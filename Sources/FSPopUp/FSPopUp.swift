import UIKit

public protocol FSStateSetuping {
    associatedtype State
    func setup(with state: State)
}

public enum FSPopUpPosition {
    case top(offset: CGFloat)
    case center(offset: CGFloat)
    case bottom(offset: CGFloat)
}

public enum FSPopUpSizeType {
    case constant(CGFloat)
    case ratio(CGFloat)
    case auto
}

public enum FSPopUpButtonAlignment {
    case vertical
    case horizontal
}

public struct FSPopUpAction<T> {
    let state: T
    let handler: (() -> Void)
}

public struct FSPopUpConfiguration {
    public var width: FSPopUpSizeType = .constant(300)
    public var height: FSPopUpSizeType = .auto
    public var position: FSPopUpPosition = .center(offset: 0)
    public var blur: UIBlurEffect? = nil
    public var backgroundColor: UIColor? = nil
    public var transitionStyle: FSPopUpTransitionStyle = .bounceUp
    public var cornerRadius: CGFloat = 12
    public var stackConfiguration: FSPopUpStackViewConfiguration = .init()
    public var isDismissOnSwipe: Bool = true
    
    public init() {}
}

final public class FSPopUp<Template: UIView & FSStateSetuping, State>: UIViewController where Template.State == State {
    
    // MARK: - Nested types
    
    // MARK: - Private properties
    
    private var popupContainerView = PopUpContainerView()
    private var contentView: UIView
    private var actions: [FSPopUpAction<State>]
    private var buttonTemplate: Template.Type
    
    fileprivate lazy var interactor = FSInteractiveTransition()
    
    private let viewController: UIViewController
    
    fileprivate var presentationManager: FSPresentationManager!
    
    private let configuration: FSPopUpConfiguration
    fileprivate var buttons = [FSPopUpButton]()
    
    // MARK: - Initialiser
    
    public init(viewController: UIViewController, buttonTemplate: Template.Type, configuration: FSPopUpConfiguration, actions: [FSPopUpAction<State>]) {
        self.viewController = viewController
        self.configuration = configuration
        self.actions = actions
        self.buttonTemplate = buttonTemplate
        self.contentView = viewController.view
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = presentationManager
        modalPresentationStyle = .custom
        
        interactor.viewController = self
        self.presentationManager = FSPresentationManager(transitionStyle: configuration.transitionStyle, interactor: interactor, backgroundColor: configuration.backgroundColor, blur: configuration.blur)
        
        modalPresentationCapturesStatusBarAppearance = true
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        popupContainerView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        popupContainerView.layer.cornerRadius = configuration.cornerRadius
        popupContainerView.clipsToBounds = true
        popupContainerView.layer.shadowColor = UIColor.black.cgColor
        popupContainerView.layer.shadowRadius = 8
        contentView.translatesAutoresizingMaskIntoConstraints = false
        popupContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupContainerView)
        popupContainerView.setup(contentView: contentView, button: Template.self, actions: actions, configuration: .init())
        configureSize()
        configurePosition()
        configureGestures()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        print("viewWillAppear")
   }
    
    @objc private func buttonTapped(_ button: FSPopUpButton) {
        print("buttonTapped")
        //button.action()
    }
    
    private func configurePosition() {
        switch configuration.position {
        case .top(let offset):
            NSLayoutConstraint.activate([
                popupContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset),
                popupContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        case .center:
            NSLayoutConstraint.activate([
                popupContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                popupContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        case .bottom(let offset):
            NSLayoutConstraint.activate([
                popupContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: offset),
                popupContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
    }
    
    private func configureSize() {
        switch configuration.width {
        case .constant(let width):
            NSLayoutConstraint.activate([
                popupContainerView.widthAnchor.constraint(equalToConstant: width)
            ])
        case .ratio(let ratio):
            NSLayoutConstraint.activate([
                popupContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: ratio)
            ])
        case .auto:
            NSLayoutConstraint.activate([
                popupContainerView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor)
            ])
        }

        switch configuration.height {
        case .constant(let height):
            NSLayoutConstraint.activate([
                popupContainerView.heightAnchor.constraint(equalToConstant: height)
            ])
        case .ratio(let ratio):
            NSLayoutConstraint.activate([
                popupContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: ratio),
            ])
        case .auto:
            NSLayoutConstraint.activate([
                popupContainerView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor)
            ])
        }
    }
    
    private func configureGestures() {
        if configuration.isDismissOnSwipe {
            let panRecognizer = UIPanGestureRecognizer(target: interactor, action: #selector(FSInteractiveTransition.handlePan))
            panRecognizer.cancelsTouchesInView = false
            popupContainerView.addGestureRecognizer(panRecognizer)
        }
    }
}
