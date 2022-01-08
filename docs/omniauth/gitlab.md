# Omniauth GitLab

This document will show you how to setup login with GitLab, it also support your self hosted GitLab.

## Create GitLab Application

Visit https://gitlab.com/profile/applications or https://your-gitlab.com/profile/applications

The visit path is: "User Settings" -> "Applications" to enter the "Add new application" page.

Fill in the info in form.

- Name: BlueDoc
- Redirect URI: https://your-bluedoc.com/account/auth/gitlab/callback
- Scopes: api, read_user, openid

> NOTE: the callback url path must equal to "${your-host}/account/auth/gitlab/callback", please do not change path
> And please makesure enabled `api`, `read_user`, `openid` in Scopes!!


After form submited, you will get the:

- Application ID
- Secret

## Setup BlueDoc

You need custom two environment:

```
OMNIAUTH_GITLAB_CLIENT_ID=your-application-id
OMNIAUTH_GITLAB_CLIENT_SECRET=your-secret
```

If you configure with your self hosted GitLab, you need other environment variable:

```
OMNIAUTH_GITLAB_API_PREFIX=https://your-gitlab.com/api/v4
```

`OMNIAUTH_GITLAB_API_PREFIX` default value is "https://gitlab.com/api/v4"

when you setup that and start BlueDoc, you will see the "Sign in with GitLab" button, on Sign in page.