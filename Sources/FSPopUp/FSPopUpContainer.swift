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
    
    let buttonTest: UIButton = {
        let button = UIButton()
        button.setTitle("TEST", for: .normal)
        return button
    }()
    
    lazy var buttons: [FSPopUpButton] = [FSPopUpButton(frame: .zero, contentView: buttonTest , action: {})]
    
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
//        buttons.forEach {
//            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
//            buttonsStackView.addArrangedSubview($0)
//        }
        buttons[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
        
        buttonsStackView.addArrangedSubview(buttons[0])
        
        buttonsStackView.axis = configuration.axis
        buttonsStackView.spacing = configuration.spacing
        buttonsStackView.alignment = configuration.alignment
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.backgroundColor = .clear
        buttonsStackView.isUserInteractionEnabled = true
        
        actions.forEach { action in
            let button = View.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            button.setup(with: action.state)
            let popUpButton = FSPopUpButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100), contentView: button, action: action.handler)
            buttonsStackView.addArrangedSubview(popUpButton)
            buttons.append(popUpButton)
            popUpButton.isUserInteractionEnabled = true
            popUpButton.heightAnchor.constraint(equalToConstant: configuration.itemHeight).isActive = true
            popUpButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        buttons.forEach {
            print($0 ,$0.allTargets)
        }
    }
    
    @objc func buttonTapped() {
        print("buttonTappedddd!!!")
    }
}
