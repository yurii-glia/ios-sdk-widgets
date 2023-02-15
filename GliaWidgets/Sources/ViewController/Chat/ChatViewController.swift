import MobileCoreServices
import UIKit

class ChatViewController: EngagementViewController, MediaUpgradePresenter,
    PopoverPresenter, ScreenShareOfferPresenter {
    private var viewModel: SecureConversations.ChatWithTranscriptModel
    private var lastVisibleRowIndexPath: IndexPath?

    init(viewModel: SecureConversations.ChatWithTranscriptModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel.engagementModel, viewFactory: viewFactory)
    }

    override public func loadView() {
        let view = viewFactory.makeChatView()
        self.view = view

        bind(viewModel: viewModel, to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.chat(.viewDidLoad))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is called to update message entry view height
        // on every font size change
        (self.view as? ChatView)?.messageEntryView.updateLayout()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewFactory.theme.chat.preferredStatusBarStyle
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let view = view as? ChatView else { return }
        lastVisibleRowIndexPath = view.tableView.indexPathsForVisibleRows?.last
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard let view = view as? ChatView else { return }
        guard let indexPath = lastVisibleRowIndexPath else { return }
        view.tableView.reloadData()
        view.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // swiftlint:disable function_body_length
    private func bind(viewModel: SecureConversations.ChatWithTranscriptModel, to view: ChatView) {
        view.header.showBackButton()
        view.header.showCloseButton()

        view.numberOfSections = { [viewModel] in
            viewModel.numberOfSections
        }
        view.numberOfRows = { [viewModel] rows in
            viewModel.numberOfItems(in: rows)
        }
        view.itemForRow = { [viewModel] row, section in
            viewModel.item(for: row, in: section)
        }
        view.messageEntryView.textChanged = { [viewModel] text in
            viewModel.event(.chat(.messageTextChanged(text)))
        }
        view.messageEntryView.sendTapped = { [viewModel] in
            viewModel.event(.chat(.sendTapped))
        }
        view.messageEntryView.pickMediaTapped = { [viewModel] in
            viewModel.event(.chat(.pickMediaTapped))
        }
        view.fileTapped = { [viewModel] file in
            viewModel.event(.chat(.fileTapped(file)))
        }
        view.downloadTapped = { [viewModel] download in
            viewModel.event(.chat(.downloadTapped(download)))
        }
        view.callBubbleTapped = { [viewModel] in
            viewModel.event(.chat(.callBubbleTapped))
        }
        view.choiceOptionSelected = { [viewModel] option, messageId in
            viewModel.event(.chat(.choiceOptionSelected(option, messageId)))
        }
        view.chatScrolledToBottom = { [viewModel] bottomReached in
            viewModel.event(.chat(.chatScrolled(bottomReached: bottomReached)))
        }
        view.linkTapped = { [viewModel] url in
            viewModel.event(.chat(.linkTapped(url)))
        }
        view.selectCustomCardOption = { [viewModel] option, messageId in
            viewModel.event(.chat(.customCardOptionSelected(option: option, messageId: messageId)))
        }

        var viewModel = viewModel

        viewModel.action = { [weak self] action in
            guard case let .chat(chatAction) = action else { return }
            switch chatAction {
            case .queue:
                view.setConnectState(.queue, animated: false)
            case .connected(let name, let imageUrl):
                view.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
                view.messageEntryView.isConnected = true
            case .setMessageEntryEnabled(let enabled):
                view.messageEntryView.isEnabled = enabled
            case .setChoiceCardInputModeEnabled(let enabled):
                view.messageEntryView.isChoiceCardModeEnabled = enabled
            case .setMessageText(let text):
                view.messageEntryView.messageText = text
            case .sendButtonHidden(let hidden):
                view.messageEntryView.showsSendButton = !hidden
            case .pickMediaButtonEnabled(let enabled):
                view.messageEntryView.pickMediaButton.isEnabled = enabled
            case .appendRows(let count, let section, let animated):
                view.appendRows(count, to: section, animated: animated)
            case .refreshRow(let row, let section, let animated):
                view.refreshRow(row, in: section, animated: animated)
            case .refreshRows(let rows, let section, let animated):
                view.refreshRows(rows, in: section, animated: animated)
            case .refreshSection(let section):
                view.refreshSection(section)
            case .refreshAll:
                view.refreshAll()
            case .scrollToBottom(let animated):
                view.scrollToBottom(animated: animated)
            case .updateItemsUserImage(let animated):
                view.updateItemsUserImage(animated: animated)
            case .addUpload:
                // Handled by data-driven SecureConversations.FileUploadListView.
                break
            case .removeUpload:
                // Handled by data-driven SecureConversations.FileUploadListView.
                break
            case .removeAllUploads:
                view.messageEntryView.uploadListView.removeAllUploadViews()
            case .presentMediaPicker(let itemSelected):
                self?.presentMediaPicker(
                    from: view.messageEntryView.pickMediaButton,
                    itemSelected: itemSelected
                )
            case .offerMediaUpgrade(let conf, let accepted, let declined):
                self?.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .showCallBubble(let imageUrl):
                view.showCallBubble(with: imageUrl, animated: true)
            case .updateUnreadMessageIndicator(let count):
                view.unreadMessageIndicatorView.newItemCount = count
            case .setOperatorTypingIndicatorIsHiddenTo(let isHidden, let isChatScrolledToBottom):
                if isChatScrolledToBottom {
                    view.scrollToBottom(animated: true)
                }
                view.setOperatorTypingIndicatorIsHidden(to: isHidden)
            case .setIsAttachmentButtonHidden(let isHidden):
                view.messageEntryView.isAttachmentButtonHidden = isHidden
            case .transferring:
                view.setConnectState(.transferring, animated: true)
            case .setCallBubbleImage(let imageUrl):
                view.setCallBubbleImage(with: imageUrl)
            case .setUnreadMessageIndicatorImage(let imageUrl):
                view.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
            case let .fileUploadListPropsUpdated(fileUploadListProps):
                view.messageEntryView.uploadListView.props = fileUploadListProps
            }
        }
    }

    private func presentMediaPicker(
        from sourceView: UIView,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    ) {
        presentPopover(
            with: viewFactory.theme.chat.pickMedia,
            from: sourceView,
            arrowDirections: [.down],
            itemSelected: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                itemSelected($0)
            }
        )
    }
}