## Security TODO

- Restrict TLS versions to `TLSv1.2 TLSv1.3` only.
- Enable `server_tokens off;` in `http {}`.
- Add HSTS (`Strict-Transport-Security`) once HTTPS is stable.
- Add request rate limiting for the API vhost.
- Review proxy headers (e.g., `X-Forwarded-Host`, `X-Forwarded-Port`).
