import OpenAPI

struct MockAPI: APIProtocol {
    var updateEventHandler: @Sendable (Operations.UpdateEvent.Input) async throws -> Operations.UpdateEvent.Output = { _ in
        fatalError("MockAPI: updateEvent unimplemented")
    }
    var deleteEventHandler: @Sendable (Operations.DeleteEvent.Input) async throws -> Operations.DeleteEvent.Output = { _ in
        fatalError("MockAPI: deleteEvent unimplemented")
    }
    var markEventAsSeenHandler: @Sendable (Operations.MarkEventAsSeen.Input) async throws -> Operations.MarkEventAsSeen.Output = { _ in
        fatalError("MockAPI: markEventAsSeen unimplemented")
    }
    var sendNotificationHandler: @Sendable (Operations.SendNotification.Input) async throws -> Operations.SendNotification.Output = { _ in
        fatalError("MockAPI: sendNotification unimplemented")
    }
    var createAccountHandler: @Sendable (Operations.CreateAccount.Input) async throws -> Operations.CreateAccount.Output = { _ in
        fatalError("MockAPI: createAccount unimplemented")
    }
    var modifyAccountHandler: @Sendable (Operations.ModifyAccount.Input) async throws -> Operations.ModifyAccount.Output = { _ in
        fatalError("MockAPI: modifyAccount unimplemented")
    }
    var deleteAccountHandler: @Sendable (Operations.DeleteAccount.Input) async throws -> Operations.DeleteAccount.Output = { _ in
        fatalError("MockAPI: deleteAccount unimplemented")
    }
    var updateRoleHandler: @Sendable (Operations.UpdateRole.Input) async throws -> Operations.UpdateRole.Output = { _ in
        fatalError("MockAPI: updateRole unimplemented")
    }
    var linkFCMTokenToAccountHandler: @Sendable (Operations.LinkFCMTokenToAccount.Input) async throws -> Operations.LinkFCMTokenToAccount.Output = { _ in
        fatalError("MockAPI: linkFCMTokenToAccount unimplemented")
    }
    var submitFeedbackHandler: @Sendable (Operations.SubmitFeedback.Input) async throws -> Operations.SubmitFeedback.Output = { _ in
        fatalError("MockAPI: submitFeedback unimplemented")
    }
    var startFeedbackEventHandler: @Sendable (Operations.StartFeedbackEvent.Input) async throws -> Operations.StartFeedbackEvent.Output = { _ in
        fatalError("MockAPI: startFeedbackEvent unimplemented")
    }
    var createEventHandler: @Sendable (Operations.CreateEvent.Input) async throws -> Operations.CreateEvent.Output = { _ in
        fatalError("MockAPI: createEvent unimplemented")
    }
    var joinEventHandler: @Sendable (Operations.JoinEvent.Input) async throws -> Operations.JoinEvent.Output = { _ in
        fatalError("MockAPI: joinEvent unimplemented")
    }
    var logoutHandler: @Sendable (Operations.Logout.Input) async throws -> Operations.Logout.Output = { _ in
        fatalError("MockAPI: logout unimplemented")
    }
    var getBootstrapHandler: @Sendable (Operations.GetBootstrap.Input) async throws -> Operations.GetBootstrap.Output = { _ in
        fatalError("MockAPI: getBootstrap unimplemented")
    }
    var getBoostrapUpdateHandler: @Sendable (Operations.GetBoostrapUpdate.Input) async throws -> Operations.GetBoostrapUpdate.Output = { _ in
        fatalError("MockAPI: getBoostrapUpdate unimplemented")
    }
    var markActivityAsSeenHandler: @Sendable (Operations.MarkActivityAsSeen.Input) async throws -> Operations.MarkActivityAsSeen.Output = { _ in
        fatalError("MockAPI: markActivityAsSeen unimplemented")
    }

    func updateEvent(_ input: Operations.UpdateEvent.Input) async throws -> Operations.UpdateEvent.Output {
        try await updateEventHandler(input)
    }

    func deleteEvent(_ input: Operations.DeleteEvent.Input) async throws -> Operations.DeleteEvent.Output {
        try await deleteEventHandler(input)
    }

    func markEventAsSeen(_ input: Operations.MarkEventAsSeen.Input) async throws -> Operations.MarkEventAsSeen.Output {
        try await markEventAsSeenHandler(input)
    }

    func sendNotification(_ input: Operations.SendNotification.Input) async throws -> Operations.SendNotification.Output {
        try await sendNotificationHandler(input)
    }

    func createAccount(_ input: Operations.CreateAccount.Input) async throws -> Operations.CreateAccount.Output {
        try await createAccountHandler(input)
    }

    func modifyAccount(_ input: Operations.ModifyAccount.Input) async throws -> Operations.ModifyAccount.Output {
        try await modifyAccountHandler(input)
    }

    func deleteAccount(_ input: Operations.DeleteAccount.Input) async throws -> Operations.DeleteAccount.Output {
        try await deleteAccountHandler(input)
    }

    func updateRole(_ input: Operations.UpdateRole.Input) async throws -> Operations.UpdateRole.Output {
        try await updateRoleHandler(input)
    }

    func linkFCMTokenToAccount(_ input: Operations.LinkFCMTokenToAccount.Input) async throws -> Operations.LinkFCMTokenToAccount.Output {
        try await linkFCMTokenToAccountHandler(input)
    }

    func submitFeedback(_ input: Operations.SubmitFeedback.Input) async throws -> Operations.SubmitFeedback.Output {
        try await submitFeedbackHandler(input)
    }

    func startFeedbackEvent(_ input: Operations.StartFeedbackEvent.Input) async throws -> Operations.StartFeedbackEvent.Output {
        try await startFeedbackEventHandler(input)
    }

    func createEvent(_ input: Operations.CreateEvent.Input) async throws -> Operations.CreateEvent.Output {
        try await createEventHandler(input)
    }

    func joinEvent(_ input: Operations.JoinEvent.Input) async throws -> Operations.JoinEvent.Output {
        try await joinEventHandler(input)
    }

    func logout(_ input: Operations.Logout.Input) async throws -> Operations.Logout.Output {
        try await logoutHandler(input)
    }

    func getBootstrap(_ input: Operations.GetBootstrap.Input) async throws -> Operations.GetBootstrap.Output {
        try await getBootstrapHandler(input)
    }

    func getBoostrapUpdate(_ input: Operations.GetBoostrapUpdate.Input) async throws -> Operations.GetBoostrapUpdate.Output {
        try await getBoostrapUpdateHandler(input)
    }

    func markActivityAsSeen(_ input: Operations.MarkActivityAsSeen.Input) async throws -> Operations.MarkActivityAsSeen.Output {
        try await markActivityAsSeenHandler(input)
    }
}
