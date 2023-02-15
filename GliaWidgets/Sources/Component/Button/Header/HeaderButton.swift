import UIKit
import PureLayout

class HeaderButton: UIButton {
    var tap: (() -> Void)?

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private let style: HeaderButtonStyle
    private let kSize = CGSize(width: 30, height: 30)
    private var isDefineLayoutNeeded = true

    init(with style: HeaderButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        defer { super.updateConstraints() }
        if isDefineLayoutNeeded {
            isDefineLayoutNeeded = false
            defineLayout()
        }
    }

    private func setup() {
        tintColor = style.color
        setImage(style.image, for: .normal)
        setImage(style.image, for: .highlighted)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        accessibilityLabel = style.accessibility.label
        accessibilityHint = style.accessibility.hint
    }

    private func defineLayout() {
        autoSetDimensions(to: kSize)
    }

    @objc private func tapped() {
        tap?()
    }
}