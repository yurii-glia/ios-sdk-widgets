import UIKit

class UserImageView: UIView {
    private let style: UserImageStyle
    private let placeholderImageView = UIImageView()
    private let imageView = ImageView()

    init(with style: UserImageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        layer.cornerRadius = bounds.height / 2.0
        updatePlaceholderContentMode()
    }

    func setImage(_ image: UIImage?, animated: Bool) {
        changeImageVisibility(visible: image != nil)
        imageView.setImage(image, animated: animated)
    }

    func setImage(fromUrl url: String?, animated: Bool) {
        imageView.setImage(
            from: url,
            animated: animated,
            imageReceived: { [weak self] image in
                self?.changeImageVisibility(visible: image != nil)
            }
        )
    }

    private func setup() {
        clipsToBounds = true

        placeholderImageView.image = style.placeholderImage
        placeholderImageView.tintColor = style.placeholderColor
        placeholderImageView.backgroundColor = style.placeholderBackgroundColor
        updatePlaceholderContentMode()

        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = style.imageBackgroundColor
    }

    private func layout() {
        addSubview(placeholderImageView)
        placeholderImageView.autoPinEdgesToSuperviewEdges()

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }

    private func updatePlaceholderContentMode() {
        guard let image = placeholderImageView.image else { return }

        if placeholderImageView.frame.size.width > image.size.width &&
            placeholderImageView.frame.size.height > image.size.height {
            placeholderImageView.contentMode = .center
        } else {
            placeholderImageView.contentMode = .scaleAspectFit
        }
    }

    private func changeImageVisibility(visible: Bool) {
        placeholderImageView.isHidden = visible
        imageView.isHidden = !visible
    }
}
