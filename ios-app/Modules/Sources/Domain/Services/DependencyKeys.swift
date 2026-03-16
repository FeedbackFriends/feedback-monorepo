import ComposableArchitecture

public extension DependencyValues {
	var apiClient: APIClient {
		get { self[APIClient.self] }
		set { self[APIClient.self] = newValue }
	}
}

public extension DependencyValues {
	var authClient: AuthClient {
		get { self[AuthClient.self] }
		set { self[AuthClient.self] = newValue }
	}
}

public extension DependencyValues {
	var notificationClient: NotificationClient {
		get { self[NotificationClient.self] }
		set { self[NotificationClient.self] = newValue }
	}
}

public extension DependencyValues {
	var systemClient: SystemClient {
		get { self[SystemClient.self] }
		set { self[SystemClient.self] = newValue }
	}
}
