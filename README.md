# BookLab

## Development

You need install depends softwares first:

```bash
$ brew install node imagemagic postgresql elasticearch redis
```

Start development server:

- `./bin/webpack-dev-server` - to start webpack dev server.
- `rails s` - to start rails

```bash
$ ./bin/webpack-dev-server
```

In other Termal tab:

```bash
$ rails s
```

### Generate Admin

```bash
$ rails g scaffold_controller admin/repository slug:string name:string user:references description:string
```