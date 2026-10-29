### Accounts and sign-ups

Reactive Resume has its own accounts, independent from YunoHost users. Sign-ups and email/password sign-in can be disabled from the config panel (*Applications > Reactive Resume > Configuration*).

### Files

- Application and generated configuration: `__INSTALL_DIR__` (do not edit `.env`, it is regenerated on every upgrade)
- Uploaded pictures and files: `__DATA_DIR__/uploads`
- Logs: `/var/log/__APP__/__APP__.log`

### Additional settings (SSO with an OpenID Connect provider, AI, social sign-in…)

Any [environment variable supported by Reactive Resume](https://docs.rxresu.me/self-hosting/environment-variables) can be added to `__DATA_DIR__/custom.env`. This file is not created by default, is kept across upgrades, is included in backups and takes precedence over the generated `.env`. For example, to sign in through an OpenID Connect provider (Authelia, Authentik, Keycloak…) as described in the [upstream SSO guide](https://docs.rxresu.me/self-hosting/sso):

```bash
OAUTH_PROVIDER_NAME="Company SSO"
OAUTH_CLIENT_ID="your-client-id"
OAUTH_CLIENT_SECRET="your-client-secret"
OAUTH_DISCOVERY_URL="https://sso.example.com/.well-known/openid-configuration"
```

The redirect URI to declare in your provider is `https://__DOMAIN__/api/auth/callback/custom`.

Then protect the file and restart the app:

```bash
sudo chown __APP__:__APP__ __DATA_DIR__/custom.env
sudo chmod 600 __DATA_DIR__/custom.env
sudo systemctl restart __APP__
```

### Migrating from Reactive Resume v4

v4 used a different database, which cannot be upgraded in place. Install this package as a new instance and move users and resumes over as explained in the [upstream migration guide](https://docs.rxresu.me/self-hosting/migration).
