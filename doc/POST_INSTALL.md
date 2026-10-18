Open <https://__DOMAIN__> and create your account.

Until you disable it, **anyone who can reach the app can sign up**. Once your account(s) exist, you can disable sign-ups in the app's config panel (*Applications > Reactive Resume > Configuration*) or with:

```bash
sudo yunohost app config set __APP__ main.accounts.disable_signups -v yes
```

Emails (address verification, password reset) are sent from `__APP__@__DOMAIN__` through YunoHost's mail server.
