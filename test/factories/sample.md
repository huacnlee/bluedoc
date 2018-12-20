# Markdown Sample

> Welcome to use Markdown 🎉

[GitHub](http://github.com)

![GitHub Logo](/images/logo.png)
Format: ![Alt Text](https://github.com)

Sometimes you want numbered lists:

1. One
2. Two
3. Three

@someone Hello there.

## Sometimes you want bullet points:

* Start a line with a star
* Profit!

**Alternatively,**

- Dashes work just as well
- And if you have sub points, put two spaces before the dash or star:
  - Like this
  - And this

```rb
class BookLab
  class << self
    def markdown
      BookLab::HTML.render("Hello **world**")
    end
  end
end
```

## PlantUML

```plantuml
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
@enduml
```

### Test HTML chars

The `<>`, `><`, `>` and `<` will keep, but <b>will</b> will render as html.

### 全是中文

## Tables

First Header | Second Header
------------ | -------------
Content from cell 1 | Content from cell 2
Content in the first column | Content in the second column
