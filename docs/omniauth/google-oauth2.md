# Omniauth Google OAuth2

This document will show you how to setup login with Google OAuth2.

## Create Google Credentials

Visit https://console.developers.google.com/apis/credentials

To create a `web app` **OAuth Client ID**

to get:

- client_id
- client_secret

And then visit: https://console.developers.google.com/apis/library/plus.googleapis.com?q=Google%2B%20API&id=98f0e0cd-7dc7-469a-baac-d5ed9a99e403

To enable Google Plus API.

## Setup BookLab

You need custom two environment:

```
OMNIAUTH_GOOGLE_CLIENT_ID=xxxx
OMNIAUTH_GOOGLE_CLIENT_SECRET=xxxx
```

when you setup that and start BookLab, you will see the "Sign in with Google" button, on Sign in page.