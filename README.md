# BookLab

[![CircleCI](https://circleci.com/gh/huacnlee/booklab/tree/master.svg?style=shield)](https://circleci.com/gh/huacnlee/booklab/tree/master)

## Development

You need install depends softwares first:

```bash
$ brew install node imagemagick postgresql elasticsearch redis
```

Start development server:

- `yarn start` - to start webpack dev server.
- `rails s` - to start rails

```bash
$ yarn start
```

In other Termal tab:

```bash
$ rails s
```

### Generate Admin

```bash
$ rails g scaffold_controller admin/repository slug:string name:string user:references description:string
```
