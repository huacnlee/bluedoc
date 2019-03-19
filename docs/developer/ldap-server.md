Use Docker LDAP to start LDAP Server for Development environment.

- https://github.com/osixia/docker-openldap
- https://github.com/osixia/docker-phpLDAPadmin

## Start LDAP Server and Web Admin

```bash
./bin/start-ldap-service
```

Now, you can visit: http://localhost:6443 to manage LDAP Server, and add some accounts for login test.

Login Admin:

> NOTE: Username is full of `cn=admin,dc=example,dc=org`

- Username: cn=admin,dc=example,dc=org
- Password: admin

After you add a lot of accounts, you can run docker command to check accounts in LDAP Server:

```bash
docker exec ldap-service ldapsearch -x -H  ldap://localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
```