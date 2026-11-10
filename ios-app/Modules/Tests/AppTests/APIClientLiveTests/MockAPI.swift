import OpenAPI

struct MockAPI: APIProtocol {
    func suggestionInbox(_ input: Operations.SuggestionInbox.Input) async throws -> Operations.SuggestionInbox.Output {
        fatalError("MockAPI: web-only suggestionInbox unimplemented")
    }
    func publishSuggestionDecision(_ input: Operations.PublishSuggestionDecision.Input) async throws -> Operations.PublishSuggestionDecision.Output {
        fatalError("MockAPI: web-only publishSuggestionDecision unimplemented")
    }

    var reportSuggestionHandler: @Sendable (Operations.ReportSuggestion.Input) async throws -> Operations.ReportSuggestion.Output = { _ in
        fatalError("MockAPI: reportSuggestion unimplemented")
    }
    func reportSuggestion(_ input: Operations.ReportSuggestion.Input) async throws -> Operations.ReportSuggestion.Output {
        try await reportSuggestionHandler(input)
    }

    var reportedSuggestionsHandler: @Sendable (Operations.ReportedSuggestions.Input) async throws -> Operations.ReportedSuggestions.Output = { _ in
        fatalError("MockAPI: reportedSuggestions unimplemented")
    }
    func reportedSuggestions(_ input: Operations.ReportedSuggestions.Input) async throws -> Operations.ReportedSuggestions.Output {
        try await reportedSuggestionsHandler(input)
    }

    var moderateSuggestionHandler: @Sendable (Operations.ModerateSuggestion.Input) async throws -> Operations.ModerateSuggestion.Output = { _ in
        fatalError("MockAPI: moderateSuggestion unimplemented")
    }
    func moderateSuggestion(_ input: Operations.ModerateSuggestion.Input) async throws -> Operations.ModerateSuggestion.Output {
        try await moderateSuggestionHandler(input)
    }

    var listSuggestionsHandler: @Sendable (Operations.ListSuggestions.Input) async throws -> Operations.ListSuggestions.Output = { _ in
        fatalError("MockAPI: listSuggestions unimplemented")
    }
    func listSuggestions(_ input: Operations.ListSuggestions.Input) async throws -> Operations.ListSuggestions.Output {
        try await listSuggestionsHandler(input)
    }

    var createSuggestionHandler: @Sendable (Operations.CreateSuggestion.Input) async throws -> Operations.CreateSuggestion.Output = { _ in
        fatalError("MockAPI: createSuggestion unimplemented")
    }
    func createSuggestion(_ input: Operations.CreateSuggestion.Input) async throws -> Operations.CreateSuggestion.Output {
        try await createSuggestionHandler(input)
    }

    var setSuggestionSupportHandler: @Sendable (Operations.SetSuggestionSupport.Input) async throws -> Operations.SetSuggestionSupport.Output = { _ in
        fatalError("MockAPI: setSuggestionSupport unimplemented")
    }
    func setSuggestionSupport(_ input: Operations.SetSuggestionSupport.Input) async throws -> Operations.SetSuggestionSupport.Output {
        try await setSuggestionSupportHandler(input)
    }

    var withdrawSuggestionHandler: @Sendable (Operations.WithdrawSuggestion.Input) async throws -> Operations.WithdrawSuggestion.Output = { _ in
        fatalError("MockAPI: withdrawSuggestion unimplemented")
    }
    func withdrawSuggestion(_ input: Operations.WithdrawSuggestion.Input) async throws -> Operations.WithdrawSuggestion.Output {
        try await withdrawSuggestionHandler(input)
    }

    var pendingLeaderInvitationsHandler: @Sendable (Operations.PendingLeaderInvitations.Input) async throws -> Operations.PendingLeaderInvitations.Output = { _ in
        fatalError("MockAPI: pendingLeaderInvitations unimplemented")
    }
    func pendingLeaderInvitations(_ input: Operations.PendingLeaderInvitations.Input) async throws -> Operations.PendingLeaderInvitations.Output {
        try await pendingLeaderInvitationsHandler(input)
    }

    var submitSupportSubmissionHandler: @Sendable (Operations.SubmitSupportSubmission.Input) async throws -> Operations.SubmitSupportSubmission.Output = { _ in
        fatalError("MockAPI: submitSupportSubmission unimplemented")
    }
    func submitSupportSubmission(_ input: Operations.SubmitSupportSubmission.Input) async throws -> Operations.SubmitSupportSubmission.Output {
        try await submitSupportSubmissionHandler(input)
    }
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

    var rejectHandler: @Sendable (Operations.Reject.Input) async throws -> Operations.Reject.Output = { _ in
        fatalError("MockAPI: reject unimplemented")
    }
    func reject(_ input: Operations.Reject.Input) async throws -> Operations.Reject.Output {
        try await rejectHandler(input)
    }

    var approveHandler: @Sendable (Operations.Approve.Input) async throws -> Operations.Approve.Output = { _ in
        fatalError("MockAPI: approve unimplemented")
    }
    func approve(_ input: Operations.Approve.Input) async throws -> Operations.Approve.Output {
        try await approveHandler(input)
    }

    var inviteLeaderHandler: @Sendable (Operations.InviteLeader.Input) async throws -> Operations.InviteLeader.Output = { _ in
        fatalError("MockAPI: inviteLeader unimplemented")
    }
    func inviteLeader(_ input: Operations.InviteLeader.Input) async throws -> Operations.InviteLeader.Output {
        try await inviteLeaderHandler(input)
    }

    var rotateHandler: @Sendable (Operations.Rotate.Input) async throws -> Operations.Rotate.Output = { _ in
        fatalError("MockAPI: rotate unimplemented")
    }
    func rotate(_ input: Operations.Rotate.Input) async throws -> Operations.Rotate.Output {
        try await rotateHandler(input)
    }

    var joinHandler: @Sendable (Operations.Join.Input) async throws -> Operations.Join.Output = { _ in
        fatalError("MockAPI: join unimplemented")
    }
    func join(_ input: Operations.Join.Input) async throws -> Operations.Join.Output {
        try await joinHandler(input)
    }

    var createOrganizationHandler: @Sendable (Operations.CreateOrganization.Input) async throws -> Operations.CreateOrganization.Output = { _ in
        fatalError("MockAPI: createOrganization unimplemented")
    }
    func createOrganization(_ input: Operations.CreateOrganization.Input) async throws -> Operations.CreateOrganization.Output {
        try await createOrganizationHandler(input)
    }

    var createTeamHandler: @Sendable (Operations.CreateTeam.Input) async throws -> Operations.CreateTeam.Output = { _ in
        fatalError("MockAPI: createTeam unimplemented")
    }
    func createTeam(_ input: Operations.CreateTeam.Input) async throws -> Operations.CreateTeam.Output {
        try await createTeamHandler(input)
    }

    var acceptLeadershipHandler: @Sendable (Operations.AcceptLeadership.Input) async throws -> Operations.AcceptLeadership.Output = { _ in
        fatalError("MockAPI: acceptLeadership unimplemented")
    }
    func acceptLeadership(_ input: Operations.AcceptLeadership.Input) async throws -> Operations.AcceptLeadership.Output {
        try await acceptLeadershipHandler(input)
    }

    var managementHandler: @Sendable (Operations.Management.Input) async throws -> Operations.Management.Output = { _ in
        fatalError("MockAPI: management unimplemented")
    }
    func management(_ input: Operations.Management.Input) async throws -> Operations.Management.Output {
        try await managementHandler(input)
    }

    var leadershipHandler: @Sendable (Operations.Leadership.Input) async throws -> Operations.Leadership.Output = { _ in
        fatalError("MockAPI: leadership unimplemented")
    }
    func leadership(_ input: Operations.Leadership.Input) async throws -> Operations.Leadership.Output {
        try await leadershipHandler(input)
    }

    var leaderInvitationHandler: @Sendable (Operations.LeaderInvitation.Input) async throws -> Operations.LeaderInvitation.Output = { _ in
        fatalError("MockAPI: leaderInvitation unimplemented")
    }
    func leaderInvitation(_ input: Operations.LeaderInvitation.Input) async throws -> Operations.LeaderInvitation.Output {
        try await leaderInvitationHandler(input)
    }

    var resolveHandler: @Sendable (Operations.Resolve.Input) async throws -> Operations.Resolve.Output = { _ in
        fatalError("MockAPI: resolve unimplemented")
    }
    func resolve(_ input: Operations.Resolve.Input) async throws -> Operations.Resolve.Output {
        try await resolveHandler(input)
    }

    var contextHandler: @Sendable (Operations.Context.Input) async throws -> Operations.Context.Output = { _ in
        fatalError("MockAPI: context unimplemented")
    }
    func context(_ input: Operations.Context.Input) async throws -> Operations.Context.Output {
        try await contextHandler(input)
    }

    var leaveHandler: @Sendable (Operations.Leave.Input) async throws -> Operations.Leave.Output = { _ in
        fatalError("MockAPI: leave unimplemented")
    }
    func leave(_ input: Operations.Leave.Input) async throws -> Operations.Leave.Output {
        try await leaveHandler(input)
    }

    var removeHandler: @Sendable (Operations.Remove.Input) async throws -> Operations.Remove.Output = { _ in
        fatalError("MockAPI: remove unimplemented")
    }
    func remove(_ input: Operations.Remove.Input) async throws -> Operations.Remove.Output {
        try await removeHandler(input)
    }

    var removeLeaderHandler: @Sendable (Operations.RemoveLeader.Input) async throws -> Operations.RemoveLeader.Output = { _ in
        fatalError("MockAPI: removeLeader unimplemented")
    }
    func removeLeader(_ input: Operations.RemoveLeader.Input) async throws -> Operations.RemoveLeader.Output {
        try await removeLeaderHandler(input)
    }

    var revokeLeaderInviteHandler: @Sendable (Operations.RevokeLeaderInvite.Input) async throws -> Operations.RevokeLeaderInvite.Output = { _ in
        fatalError("MockAPI: revokeLeaderInvite unimplemented")
    }
    func revokeLeaderInvite(_ input: Operations.RevokeLeaderInvite.Input) async throws -> Operations.RevokeLeaderInvite.Output {
        try await revokeLeaderInviteHandler(input)
    }

    var cancelHandler: @Sendable (Operations.Cancel.Input) async throws -> Operations.Cancel.Output = { _ in
        fatalError("MockAPI: cancel unimplemented")
    }
    func cancel(_ input: Operations.Cancel.Input) async throws -> Operations.Cancel.Output {
        try await cancelHandler(input)
    }
}
