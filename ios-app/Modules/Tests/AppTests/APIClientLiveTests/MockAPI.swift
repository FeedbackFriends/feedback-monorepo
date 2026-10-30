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
    var markNotificationHistoryAsSeenHandler: @Sendable (Operations.MarkNotificationHistoryAsSeen.Input) async throws -> Operations.MarkNotificationHistoryAsSeen.Output = { _ in
        fatalError("MockAPI: markNotificationHistoryAsSeen unimplemented")
    }

    var updateActivityHandler: @Sendable (Operations.UpdateActivity.Input) async throws -> Operations.UpdateActivity.Output = { _ in
        fatalError("MockAPI: updateActivity unimplemented")
    }

    func updateActivity(_ input: Operations.UpdateActivity.Input) async throws -> Operations.UpdateActivity.Output {
        try await updateActivityHandler(input)
    }

    var deleteActivityHandler: @Sendable (Operations.DeleteActivity.Input) async throws -> Operations.DeleteActivity.Output = { _ in
        fatalError("MockAPI: deleteActivity unimplemented")
    }

    func deleteActivity(_ input: Operations.DeleteActivity.Input) async throws -> Operations.DeleteActivity.Output {
        try await deleteActivityHandler(input)
    }

    var createActivityHandler: @Sendable (Operations.CreateActivity.Input) async throws -> Operations.CreateActivity.Output = { _ in
        fatalError("MockAPI: createActivity unimplemented")
    }

    func createActivity(_ input: Operations.CreateActivity.Input) async throws -> Operations.CreateActivity.Output {
        try await createActivityHandler(input)
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

    func markNotificationHistoryAsSeen(_ input: Operations.MarkNotificationHistoryAsSeen.Input) async throws -> Operations.MarkNotificationHistoryAsSeen.Output {
        try await markNotificationHistoryAsSeenHandler(input)
    }
}
