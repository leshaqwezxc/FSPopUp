import UIKit

public struct FSPopUpStackViewConfiguration {
    public var axis: NSLayoutConstraint.Axis = .vertical
    public var spacing: CGFloat = -1
    public var alignment: UIStackView.Alignment = .fill
    public var itemHeight: CGFloat = 40
    public var verticalPadding: CGFloat = -1
    public var horizontalPadding: CGFloat = -1
    
    public init() {}
}

final class PopUpContainerView: UIView {
    
    // MARK: - Subviews
    
    internal lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.buttonsStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    internal lazy var container: UIView = {
        let container = UIView(frame: .zero)
        return container
    }()
    
    let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var buttons: [FSPopUpButton] = []
    
    // MARK: - Initialiser
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        buttonsStackView.isUserInteractionEnabled = true
        addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func setup<View: UIView & FSStateSetuping, ActionState>(contentView: UIView, button: View.Type, actions: [FSPopUpAction<ActionState>], configuration: FSPopUpStackViewConfiguration) where View.State == ActionState {
        stackView.addArrangedSubview(contentView)
        stackView.addArrangedSubview(buttonsStackView)
        contentView.isUserInteractionEnabled = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        buttonsStackView.axis = configuration.axis
        buttonsStackView.spacing = configuration.spacing
        buttonsStackView.alignment = configuration.alignment
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.backgroundColor = .clear
        buttonsStackView.isUserInteractionEnabled = true
        
//        actions.forEach { action in
//            let button = View.init(frame: .zero)
//            button.setup(with: action.state)
//            let popUpButton = FSPopUpButton(frame: .zero, contentView: button, action: action.handler)
//            buttonsStackView.addArrangedSubview(popUpButton)
//            buttons.append(popUpButton)
//            popUpButton.isUserInteractionEnabled = true
//            popUpButton.heightAnchor.constraint(equalToConstant: configuration.itemHeight).isActive = true
//            popUpButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        }
//        
//        buttons.forEach {
//            print($0 ,$0.allTargets)
//        }
    }
    
    @objc func buttonTapped() {
        print("buttonTappedddd!!!")
    }
}
