---
name: check-upsun-auth
description: Checks Upsun authentication and login status. Use when the user asks "am I logged in to Upsun", "check Upsun authentication", "Upsun login status", "am I authenticated", "check my Upsun credentials", or wants to log in, log out, or switch Upsun accounts.
---

# Check Upsun Auth

## Check current authentication status

```bash
upsun auth:info
```

Returns the currently authenticated user's email and account details. If not authenticated, it will error.

## Authenticate

**Via browser (recommended):**
```bash
upsun auth:browser-login
```

**Via API token:**
```bash
upsun auth:api-token-login
```

## Log out

```bash
upsun auth:logout
```
