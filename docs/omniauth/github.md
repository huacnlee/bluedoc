# Omniauth GitHub

This document will show you how to setup login with GitHub.

## Create GitHub Application

Visit https://github.com/settings/applications/new

Or sign in GitHub, and then open "Settings" -> "Developer Settings" -> "New OAuth App" to enter the "Register a new OAuth application" page.

Fill in the info in form.

- Application Name: BookLab
- Homepage URL: https://your-booklab.com
- Application Description: Sign in with BookLab
- Authorization callback URL: https://your-booklab.com/account/auth/github/callback

> NOTE: the callback url path must equal to "${your-host}/account/auth/github/callback", please do not change path


After form submited, you will get the:

- client_id
- client_secret

## Setup BookLab

You need custom two environment:

```
OMNIAUTH_GITHUB_CLIENT_ID=xxxx
OMNIAUTH_GITHUB_CLIENT_SECRET=xxxx
```

when you setup that and start BookLab, you will see the "Sign in with GitHub" button, on Sign in page.