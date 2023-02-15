#if DEBUG
extension EngagementCoordinator.Environment {
    static let mock = Self.init(
        fetchFile: { _, _, _ in },
        sendSelectedOptionValue: { _, _ in },
        uploadFileToEngagement: { _, _, _ in },
        audioSession: .mock,
        uuid: { .mock },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock,
        createFileDownload: { _, _, _ in .mock() },
        loadChatMessagesFromHistory: { false },
        timerProviding: .mock,
        fetchSiteConfigurations: { _ in },
        getCurrentEngagement: { nil },
        submitSurveyAnswer: { _, _, _, _ in },
        uiApplication: .mock,
        fetchChatHistory: { _ in },
        listQueues: { _ in },
        sendSecureMessage: { _, _, _, _ in .init() },
        createFileUploader: FileUploader.mock,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
        uploadSecureFile: { _, _, _ in .mock }
    )
}
#endif