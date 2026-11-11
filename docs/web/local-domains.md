# Local web domains

Use `https://letsgrow.localhost` for marketing and `https://app.letsgrow.localhost`
for the account app. Development proxy routing keeps login, dashboard and leader
invitations on the local app domain. The marketing CTA uses `/login`, which the
proxy routes to the app domain. Production continues to use `letsgrow.dk` and
`app.letsgrow.dk`.

Map only the local names in `/etc/hosts`:

```text
127.0.0.1 letsgrow.localhost app.letsgrow.localhost
```

Do not override the public domains locally. Generate a trusted certificate with
`mkcert` and keep its key outside the repository:

```sh
mkdir -p "$HOME/Library/Caches/letsgrow-local-domains"
mkcert -cert-file "$HOME/Library/Caches/letsgrow-local-domains/cert.pem" -key-file "$HOME/Library/Caches/letsgrow-local-domains/key.pem" letsgrow.localhost app.letsgrow.localhost localhost 127.0.0.1
chmod 600 "$HOME/Library/Caches/letsgrow-local-domains/key.pem"
```

Start the local Kotlin API on port 8080 and set `FEEDBACK_API_ORIGIN=http://localhost:8080`
in the root `.env` so the web relay can reach it. Restart Next.js after changing this value.

From `web/`, using the pinned Node version, start:

```sh
npm run dev -- --hostname 0.0.0.0 --port 443 --experimental-https --experimental-https-key "$HOME/Library/Caches/letsgrow-local-domains/key.pem" --experimental-https-cert "$HOME/Library/Caches/letsgrow-local-domains/cert.pem"
```

Supabase remains the configured hosted auth service. Allow development redirects
for `https://app.letsgrow.localhost/login` and
`https://app.letsgrow.localhost/leader-invite/*` in that project's auth settings.
Request a fresh email from the local app domain; sessions and PKCE verifiers from
other origins do not carry over. This setup does not deploy any services or change
public DNS. Removing the local hosts entry disables the machine-specific mapping.
