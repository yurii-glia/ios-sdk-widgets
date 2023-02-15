import Foundation

extension SecureConversations {
    final class ConfirmationViewModel: ViewModel {
        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String { didSet { reportChange() } }

        init(environment: Environment) {
            self.environment = environment
            messageText = ""
        }

        func event(_ event: Event) {
            switch event {
            case .backTapped:
                delegate?(.backTapped)
            case .closeTapped:
                delegate?(.closeTapped)
            }
        }

        func reportChange() {
            delegate?(.renderProps(props()))
        }
    }
}

extension SecureConversations.ConfirmationViewModel {
    func props() -> SecureConversations.ConfirmationViewController.Props {
        let confirmationStyle = environment.confirmationStyle
        let confirmationViewProps = SecureConversations.ConfirmationView.Props(
            style: confirmationStyle,
            backButtonTap: Cmd { [weak self] in self?.delegate?(.backTapped) },
            closeButtonTap: Cmd { [weak self] in self?.delegate?(.closeTapped) },
            checkMessageButtonTap: Cmd { print("check messages") }
        )

        let viewControllerProps = SecureConversations.ConfirmationViewController.Props(
            confirmationViewProps: confirmationViewProps
        )

        return viewControllerProps
    }
}

extension SecureConversations.ConfirmationViewModel {
    enum Event {
        case backTapped
        case closeTapped
    }

    enum Action {
        case start
    }

    enum DelegateEvent {
        case backTapped
        case closeTapped
        case renderProps(SecureConversations.ConfirmationViewController.Props)
    }

    enum StartAction {
        case none
    }
}

extension SecureConversations.ConfirmationViewModel {
    struct Environment {
        var confirmationStyle: SecureConversations.ConfirmationStyle
    }
}