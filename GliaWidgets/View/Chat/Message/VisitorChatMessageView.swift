import UIKit

class VisitorChatMessageView: ChatMessageView {
    var status: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }

    private let statusLabel = UILabel()
    private let kInsets = UIEdgeInsets(top: 2, left: 88, bottom: 2, right: 16)

    init(
        with style: VisitorChatMessageStyle,
        environment: Environment
    ) {
        super.init(
            with: style,
            contentAlignment: .right,
            environment: environment
        )

        setup(style: style)
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(style: VisitorChatMessageStyle) {
        super.setup()
        statusLabel.font = style.statusFont
        statusLabel.textColor = style.statusColor
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: statusLabel
        )
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left, relation: .greaterThanOrEqual)

        addSubview(statusLabel)
        statusLabel.autoPinEdge(.top, to: .bottom, of: contentViews, withOffset: 2)
        statusLabel.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        statusLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
    }
}
