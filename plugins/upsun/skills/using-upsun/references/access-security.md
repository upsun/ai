# Access Control and Security

Complete guide to managing users, teams, authentication, SSH keys, and SSL certificates on Upsun.

## Overview

Upsun provides comprehensive access control at multiple levels: organization, project, and environment. Understanding the security model is essential for team collaboration and compliance.

**Security Layers:**
- **Authentication** - User identity verification
- **Organizations** - Top-level access grouping
- **Teams** - User groups with shared permissions
- **Project Users** - Individual project access
- **SSH Keys** - Secure server access
- **SSL Certificates** - HTTPS encryption

## Authentication

### Login Methods

**Browser-based login (recommended):**
```bash
upsun auth:browser-login
```

**Alias:** `login`

**What happens:**
1. Opens browser for authentication
2. Redirects to Upsun login page
3. Authenticates via OAuth
4. Stores credentials locally

**API token login:**
```bash
upsun auth:api-token-login
```

**Use for:**
- CI/CD pipelines
- Automated scripts
- Headless environments
- Service accounts

**How to get API token:**
1. Go to Upsun Console
2. Navigate to Account Settings
3. Generate API token
4. Copy token
5. Paste when prompted by CLI

### Check Authentication Status

Verify current authentication:

```bash
upsun auth:info
```

**Example output:**
```
+-----------------------+--------------------------------------+
| Property              | Value                                |
+-----------------------+--------------------------------------+
| id                    | 2ae6ca7d-f5bf-4749-b8a2-d2bedcc7459e |
| first_name            | John                                 |
| last_name             | Doe                                  |
| username              | johndoe                              |
| email                 | john.doe@example.com                 |
| phone_number_verified | false                                |
+-----------------------+--------------------------------------+
```

**Check if authenticated:**
```bash
upsun auth:info --no-interaction >/dev/null 2>&1 && echo "Authenticated" || echo "Not authenticated"
```

### Logout

Log out from Upsun:

```bash
upsun auth:logout
```

**Alias:** `logout`

**What it does:**
- Removes local credentials
- Invalidates session
- Requires re-authentication for next command

### Phone Number Verification

Verify phone number for account security:

```bash
upsun auth:verify-phone-number
```

**Interactive process:**
1. Enter phone number
2. Receive verification code
3. Enter code to verify

**Benefits:**
- Enhanced account security
- Two-factor authentication option
- Account recovery

## Project User Management

### List Project Users

View all users with access to a project:

```bash
upsun user:list -p PROJECT_ID
```

**Alias:** `users`

**Example:**
```bash
upsun users -p abc123
```

**Output:**
```
+----------------------+-------------+---------+
| Email                | Name        | Role    |
+----------------------+-------------+---------+
| admin@example.com    | Admin User  | admin   |
| dev@example.com      | Developer   | viewer  |
+----------------------+-------------+---------+
```

### Add User to Project

Grant user access to a project:

```bash
upsun user:add EMAIL -p PROJECT_ID
```

**Example:**
```bash
upsun user:add developer@example.com -p abc123
```

**With specific role:**
```bash
upsun user:add developer@example.com -p abc123 --role viewer
```

**Available roles:**
- `admin` - Full project access, can manage users
- `viewer` - Read-only access
- `contributor` - Can push code, no admin access

**Permissions by role:**

| Permission | Admin | Contributor | Viewer |
|------------|-------|-------------|--------|
| View environments | ✅ | ✅ | ✅ |
| Push code | ✅ | ✅ | ❌ |
| Deploy | ✅ | ✅ | ❌ |
| Manage users | ✅ | ❌ | ❌ |
| Delete environments | ✅ | ❌ | ❌ |
| Manage variables | ✅ | ❌ | ❌ |

### View User Details

Check a specific user's role:

```bash
upsun user:get EMAIL -p PROJECT_ID
```

**Example:**
```bash
upsun user:get developer@example.com -p abc123
```

### Update User Role

Change user's project role:

```bash
upsun user:update EMAIL -p PROJECT_ID --role NEW_ROLE
```

**Example:**
```bash
upsun user:update developer@example.com -p abc123 --role admin
```

### Remove User from Project

Revoke user's project access:

```bash
upsun user:delete EMAIL -p PROJECT_ID
```

**Example:**
```bash
upsun user:delete developer@example.com -p abc123
```

**⚠️ Warning:** User loses all access to project immediately.

## Organization User Management

### List Organization Users

View all users in an organization:

```bash
upsun organization:user:list --org ORG_ID
```

**Alias:** `org:users`

**Example:**
```bash
upsun org:users --org my-company
```

### Invite User to Organization

Add user to organization:

```bash
upsun organization:user:add --org ORG_ID
```

**Interactive prompt for:**
- User email
- Organization role
- Project assignments

**Example:**
```bash
upsun organization:user:add --org my-company
```

### View Organization User

Get details about an organization user:

```bash
upsun organization:user:get USER_ID --org ORG_ID
```

**Example:**
```bash
upsun organization:user:get john.doe@example.com --org my-company
```

### Update Organization User

Modify organization user permissions:

```bash
upsun organization:user:update USER_ID --org ORG_ID
```

**Example:**
```bash
upsun organization:user:update john.doe@example.com --org my-company --role admin
```

### Remove User from Organization

Remove user from organization:

```bash
upsun organization:user:delete USER_ID --org ORG_ID
```

**Example:**
```bash
upsun organization:user:delete john.doe@example.com --org my-company
```

### List User's Projects

See which projects a user can access:

```bash
upsun organization:user:projects USER_ID --org ORG_ID
```

**Alias:** `oups`

**Example:**
```bash
upsun oups john.doe@example.com --org my-company
```

## Team Management

### Create Team

Create a new team in an organization:

```bash
upsun team:create --org ORG_ID
```

**Example:**
```bash
upsun team:create --org my-company --label "Backend Team"
```

**Use cases:**
- Group developers by function
- Separate frontend/backend teams
- Organize by project
- Regional teams

### List Teams

View all teams in organization:

```bash
upsun team:list --org ORG_ID
```

**Alias:** `teams`

**Example:**
```bash
upsun teams --org my-company
```

### View Team Details

Get information about a specific team:

```bash
upsun team:get TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:get backend-team --org my-company
```

### Update Team

Modify team properties:

```bash
upsun team:update TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:update backend-team --org my-company --label "Backend Development Team"
```

### Delete Team

Remove a team:

```bash
upsun team:delete TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:delete old-team --org my-company
```

### Add User to Team

Grant user team membership:

```bash
upsun team:user:add TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:user:add backend-team --org my-company
# Prompts for user email
```

### List Team Users

View all members of a team:

```bash
upsun team:user:list TEAM_ID --org ORG_ID
```

**Alias:** `team:users`

**Example:**
```bash
upsun team:users backend-team --org my-company
```

### Remove User from Team

Remove team membership:

```bash
upsun team:user:delete USER_ID TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:user:delete john.doe@example.com backend-team --org my-company
```

### Add Project to Team

Grant team access to a project:

```bash
upsun team:project:add TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:project:add backend-team --org my-company
# Prompts for project selection
```

### List Team Projects

View projects a team can access:

```bash
upsun team:project:list TEAM_ID --org ORG_ID
```

**Aliases:** `team:projects`, `team:pro`

**Example:**
```bash
upsun team:projects backend-team --org my-company
```

### Remove Project from Team

Revoke team's project access:

```bash
upsun team:project:delete PROJECT_ID TEAM_ID --org ORG_ID
```

**Example:**
```bash
upsun team:project:delete abc123 backend-team --org my-company
```

## SSH Key Management

### List SSH Keys

View all SSH keys in your account:

```bash
upsun ssh-key:list
```

**Alias:** `ssh-keys`

**Example output:**
```
+-----+--------------------------------+------------------+
| ID  | Title                          | Fingerprint      |
+-----+--------------------------------+------------------+
| 123 | Laptop SSH Key                 | SHA256:abc...    |
| 456 | CI/CD Pipeline Key             | SHA256:def...    |
+-----+--------------------------------+------------------+
```

### Add SSH Key

Add a new SSH key to your account:

```bash
upsun ssh-key:add PATH_TO_PUBLIC_KEY
```

**Example:**
```bash
upsun ssh-key:add ~/.ssh/id_rsa.pub
```

**With custom title:**
```bash
upsun ssh-key:add ~/.ssh/id_ed25519.pub --title "Work Laptop"
```

**From stdin:**
```bash
cat ~/.ssh/id_rsa.pub | upsun ssh-key:add -
```

### Delete SSH Key

Remove an SSH key:

```bash
upsun ssh-key:delete KEY_ID
```

**Example:**
```bash
upsun ssh-key:delete 123
```

### Generate and Add SSH Key

**Complete workflow:**

```bash
# 1. Generate new SSH key
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/upsun_key

# 2. Start SSH agent
eval "$(ssh-agent -s)"

# 3. Add key to agent
ssh-add ~/.ssh/upsun_key

# 4. Add public key to Upsun
upsun ssh-key:add ~/.ssh/upsun_key.pub --title "Upsun Access Key"

# 5. Verify key added
upsun ssh-keys
```

### SSH Certificate

Generate SSH certificate for enhanced security:

```bash
upsun ssh-cert:load
```

**What it does:**
- Generates temporary SSH certificate
- Valid for limited time
- More secure than permanent keys
- Automatic certificate renewal

**Use for:**
- Enhanced security requirements
- Temporary access
- Compliance needs

## SSL Certificate Management

### List SSL Certificates

View all SSL certificates in a project:

```bash
upsun certificate:list -p PROJECT_ID
```

**Aliases:** `certificates`, `certs`

**Example:**
```bash
upsun certs -p abc123
```

### View Certificate Details

Get information about a specific certificate:

```bash
upsun certificate:get CERT_ID -p PROJECT_ID
```

**Example:**
```bash
upsun certificate:get 1a2b3c4d5e -p abc123
```

**Output includes:**
- Certificate ID
- Domain names covered
- Issuer
- Expiration date
- Certificate chain

### Add SSL Certificate

Add a custom SSL certificate:

```bash
upsun certificate:add CERT_FILE -p PROJECT_ID
```

**Example:**
```bash
upsun certificate:add /path/to/certificate.crt -p abc123
```

**With private key and chain:**
```bash
upsun certificate:add cert.crt --key private.key --chain chain.crt -p abc123
```

**Certificate requirements:**
- Valid X.509 certificate
- Matches domain name
- Private key included
- Chain certificates (if intermediate CAs)

### Delete SSL Certificate

Remove a certificate:

```bash
upsun certificate:delete CERT_ID -p PROJECT_ID
```

**Example:**
```bash
upsun certificate:delete 1a2b3c4d5e -p abc123
```

**⚠️ Warning:** Ensure domain has alternative certificate before deleting.

### Let's Encrypt Certificates

Upsun automatically provisions Let's Encrypt certificates for domains. Manual certificate management is only needed for:
- Custom/purchased certificates
- Wildcard certificates (not supported by Let's Encrypt on Upsun)
- Organization-specific certificate requirements
- Extended Validation (EV) certificates

## Access Control Best Practices

### Principle of Least Privilege

Grant minimum necessary permissions:

```bash
# Start with viewer role
upsun user:add newdev@example.com -p abc123 --role viewer

# Upgrade as needed
upsun user:update newdev@example.com -p abc123 --role contributor
```

### Regular Access Reviews

**Monthly audit script:**

```bash
#!/bin/bash
PROJECT="abc123"
ORG="my-company"

echo "=== Access Audit: $(date) ==="

# List project users
echo "\n--- Project Users ---"
upsun users -p $PROJECT

# List organization users
echo "\n--- Organization Users ---"
upsun org:users --org $ORG

# List teams
echo "\n--- Teams ---"
upsun teams --org $ORG

# Review and document access
echo "\nReview completed. Update access as needed."
```

### Offboarding Checklist

When removing user access:

```bash
#!/bin/bash
USER_EMAIL="departing@example.com"
ORG="my-company"

echo "Offboarding user: $USER_EMAIL"

# 1. List user's projects
echo "1. Finding user's projects..."
upsun oups $USER_EMAIL --org $ORG

# 2. Remove from each project
# (Manual step - list projects and remove)

# 3. Remove from teams
echo "2. Removing from teams..."
# (Manual step - identify teams)

# 4. Remove from organization
echo "3. Removing from organization..."
upsun organization:user:delete $USER_EMAIL --org $ORG

echo "✅ Offboarding complete"
```

### SSH Key Rotation

Rotate SSH keys regularly:

```bash
# Every 90 days
# 1. Generate new key
ssh-keygen -t ed25519 -f ~/.ssh/upsun_key_new

# 2. Add new key
upsun ssh-key:add ~/.ssh/upsun_key_new.pub --title "Rotated $(date +%Y-%m)"

# 3. Test new key
upsun ssh -p abc123 -e production

# 4. Remove old key
upsun ssh-key:delete OLD_KEY_ID

# 5. Update local SSH config
mv ~/.ssh/upsun_key_new ~/.ssh/upsun_key
```

### Two-Factor Authentication

Enable 2FA for enhanced security:

1. Verify phone number:
   ```bash
   upsun auth:verify-phone-number
   ```

2. Enable 2FA in Console:
   - Log in to Upsun Console
   - Go to Account Settings
   - Enable Two-Factor Authentication
   - Scan QR code with authenticator app

3. Store backup codes securely

## Security Compliance

### Audit Logging

Track security events:
- User additions/removals
- Role changes
- SSH key additions/deletions
- Certificate changes
- Failed login attempts

**Review via Console:**
- Organization Settings → Audit Log
- Filter by user, action, date

### Access Documentation

Document all access:

```markdown
# Project Access Matrix

## Administrators
- admin@example.com (Owner)
- lead@example.com (Admin)

## Contributors
- dev1@example.com (Backend)
- dev2@example.com (Frontend)

## Viewers
- qa@example.com (QA Team)
- stakeholder@example.com (Product Owner)

## Service Accounts
- ci-cd@example.com (GitHub Actions)

Last Updated: 2025-01-07
```

### Certificate Monitoring

Monitor certificate expiration:

```bash
#!/bin/bash
PROJECT="abc123"

echo "Checking SSL certificates..."
upsun certs -p $PROJECT | while read LINE; do
    if [[ $LINE == *"expires"* ]]; then
        EXPIRY=$(echo $LINE | grep -oP '\d{4}-\d{2}-\d{2}')
        DAYS_LEFT=$(( ($(date -d "$EXPIRY" +%s) - $(date +%s)) / 86400 ))

        if [ $DAYS_LEFT -lt 30 ]; then
            echo "⚠️  Certificate expires in $DAYS_LEFT days"
        fi
    fi
done
```

## Related Commands

**Organizations:**
- `organization:create` - Create new organization
- `organization:info` - View organization details
- See [projects-organizations.md](projects-organizations.md)

**Projects:**
- `project:info` - View project settings
- `project:list` - List accessible projects
- See [projects-organizations.md](projects-organizations.md)

**Environment Security:**
- `environment:http-access` - HTTP access control
- See [environments.md](environments.md)

## Troubleshooting

**Cannot SSH to environment:**
- Verify SSH key added: `ssh-key:list`
- Check key permissions: `chmod 600 ~/.ssh/id_rsa`
- Test SSH agent: `ssh-add -l`
- Generate new key if needed

**User cannot access project:**
- Verify user added: `user:list`
- Check user role: `user:get`
- Verify organization membership
- Check team assignments

**Certificate errors:**
- Check certificate validity
- Verify domain matches
- Ensure chain included
- Check expiration date

**Authentication fails:**
- Clear local cache: `clear-cache`
- Re-login: `auth:browser-login`
- Check API token validity
- Verify account status

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
