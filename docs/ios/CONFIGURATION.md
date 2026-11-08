# Configuration

The app reads runtime configuration from `Info.plist` using the `InfoPlist` helper.

## Keys

| Key | Example | Purpose |
| --- | --- | --- |
| `API_BASE_URL` | `api.myhost.com` | Backend host |
| `API_SCHEME` | `https` | Backend scheme |
| `WEB_BASE_URL` | `app.myhost.com` | Web deep link host |
| `WEB_SCHEME` | `https` | Web scheme |
| `SUPPORT_EMAIL` | `support@myhost.com` | Support link |
| `APPSTORE_ID` | `1234567890` | App Store links |

See `ios-app/App/InfoPlist/Info.plist` and scheme‑specific `.xcconfig` files under `ios-app/App/Config/`.

## Schemes

The default local scheme is `Feedback Localhost`; `Feedback Production` targets production. See [setup](SETUP.md) and [the harness overview](agent-harness.md) for running and testing.

## Accessing values

Example wrapper:

```19:33:ios-app/App/AppDelegate.swift
public enum InfoPlistConfig {
    public static var apiBaseUrl: URL {
        InfoPlist().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public static var supportEmail: String {
        InfoPlist().string(for: "SUPPORT_EMAIL")!
    }
    public static var webBaseUrl: URL {
        InfoPlist().url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public static var appStoreId: String {
        InfoPlist().string(for: "APPSTORE_ID")!
    }
}
```


