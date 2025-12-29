## Firewall (UFW)

Captured rules from the server. Use `apply-ufw.sh` to reset and apply.

Defaults:
- incoming: deny
- outgoing: allow
- routed: deny
- logging: low

Allowed:
- 22/tcp (SSH)
- 80/tcp (HTTP)
- 443/tcp (HTTPS)
- 8080/tcp (API)

IPv6 mirrors IPv4 rules.

Notes:
- If you switch to `nftables`, replace this file with `rules.nft`.
