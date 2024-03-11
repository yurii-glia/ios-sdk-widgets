extension Glia {
    /// Entry point for Visitor authentication.
    public struct Authentication {
        typealias Callback = (Result<Void, Error>) -> Void
        typealias GetVisitor = () -> Void

        var authenticateWithIdToken: (_ idToken: IdToken, _ accessToken: AccessToken?, _ callback: @escaping Callback) -> Void
        var deauthenticateWithCallback: (@escaping Callback) -> Void
        var isAuthenticatedClosure: () -> Bool
        var environment: Environment
    }
}

extension Glia.Authentication {
    /// Behavior for authentication and deauthentication.
    public enum Behavior {
        /// Restrict authentication and deauthentication during ongoing engagement.
        case forbiddenDuringEngagement

        case allowedDuringEngagement
    }
}

extension Glia.Authentication.Behavior {
    init(with behavior: CoreSdkClient.AuthenticationBehavior) {
        switch behavior {
        case .forbiddenDuringEngagement:
            self = .forbiddenDuringEngagement
        case .allowedDuringEngagement:
            self = .allowedDuringEngagement
        @unknown default:
            self = .forbiddenDuringEngagement
        }
    }

    func toCoreSdk() -> CoreSdkClient.AuthenticationBehavior {
        switch self {
        case .forbiddenDuringEngagement:
            return .forbiddenDuringEngagement
        case .allowedDuringEngagement:
            return .allowedDuringEngagement
        }
    }
}

extension Glia {
    /// Initiates authentication with specified behavior, manages UI state reset, 
    /// and handles authentication operations.
    ///
    /// - Parameters:
    ///   - behavior: The behavior defining how authentication should be handled.
    ///
    /// - Throws:
    ///   - `GliaCoreError(reason: "SDK is not configured properly. Make sure it is fully configured and try again.")`
    ///   
    /// - Returns:
    ///   - `Authentication` object configured with authentication operations
    ///
    /// This method prepares the authentication process according to the given behavior, 
    /// ensuring the UI is reset to its initial state upon successful authentication or deauthentication.
    /// It returns an `Authentication` instance which provides methods to authenticate with an ID token
    /// and access token, deauthenticate, and check if currently authenticated. The method also
    /// configures logging environment and cleans up UI and navigation states as necessary.
    ///
    public func authentication(with behavior: Glia.Authentication.Behavior) throws -> Authentication {
        let auth = try environment.coreSdk.authentication(behavior.toCoreSdk())

        let completion = { [weak self] in
            self?.environment.gcd.mainQueue.asyncAfterDeadline(.now() + .seconds(2)) { [weak self] in
                if self?.interactor?.currentEngagement?.restartedFromEngagementId != nil {
                    self?.rootCoordinator?.reload()
                } else {
                    // Reset navigation and UI back to initial state,
                    // effectively removing bubble view (if there was one).
                    self?.rootCoordinator?.popCoordinator()
                    self?.rootCoordinator?.end()
                    self?.rootCoordinator = nil
                }
            }
        }

        return .init(
            authenticateWithIdToken: { [weak self] idToken, accessToken, callback in
                self?.loggerPhase.logger.prefixed(Self.self).info(
                    "Authenticate. Is external access token used: \(accessToken != nil)"
                )
                auth.authenticate(
                    with: .init(rawValue: idToken),
                    externalAccessToken: accessToken.map { .init(rawValue: $0) }
                ) { result in
                    switch result {
                    case .success:
                        // Handle authentication
                        completion()

                    case .failure:
                        break
                    }

                    callback(result.mapError(Glia.Authentication.Error.init) )
                }
            },
            deauthenticateWithCallback: { [weak self] callback in
                self?.loggerPhase.logger.prefixed(Self.self).info("De-authenticate")
                auth.deauthenticate { result in
                    switch result {
                    case .success:
                        // Cleanup navigation and views.
                        completion()
                    case .failure:
                        break
                    }

                    callback(result.mapError(Glia.Authentication.Error.init))
                }
            },
            isAuthenticatedClosure: {
                auth.isAuthenticated
            },
            environment: .init(log: loggerPhase.logger)
        )
    }
}

extension Glia.Authentication {
    /// JWT token represented by `String`.
    public typealias IdToken = String

    /// Access token represented by `String`.
    public typealias AccessToken = String

    /// Authenticate visitor.
    ///
    /// - Parameters:
    ///   - idToken: JWT token for visitor authentication.
    ///   - accessToken: Access token for visitor authentication.
    ///   - completion: Completion handler.
    ///
    public func authenticate(
        with idToken: IdToken,
        accessToken: AccessToken?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.authenticateWithIdToken(
            idToken,
            accessToken,
            completion
        )
    }

    /// Deauthenticate Visitor.
    ///
    /// - Parameters:
    ///   - completion: Completion handler.
    ///
    public func deauthenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        self.deauthenticateWithCallback(completion)
    }

    /// Initialize placeholder instance.
    /// Useful during unit testing.
    public var isAuthenticated: Bool {
        self.isAuthenticatedClosure()
    }
}

extension Glia.Authentication {
    /// Authentication error.
    public struct Error: Swift.Error {
        /// Reason of error.
        public var reason: String
    }
}

extension Glia.Authentication.Error {
    init(error: CoreSdkClient.SalemoveError) {
        self.reason = error.reason
    }
}

extension Glia.Authentication {
    struct Environment {
        var log: CoreSdkClient.Logger
    }
}
