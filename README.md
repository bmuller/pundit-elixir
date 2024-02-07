# Pundit
[![Build Status](https://secure.travis-ci.org/bmuller/pundit-elixir.png?branch=master)](https://travis-ci.org/bmuller/pundit-elixir)
[![Hex pm](http://img.shields.io/hexpm/v/pundit.svg?style=flat)](https://hex.pm/packages/pundit)
[![API Docs](https://img.shields.io/badge/api-docs-lightgreen.svg?style=flat)](https://hexdocs.pm/pundit/)

Pundit provides a set of helpers which guide you in leveraging regular Elixir methods to
build a simple authorization system.  This library is based heavily on Jonas Nicklas' [Ruby project of the same name](https://github.com/varvet/pundit).

Simple Elixir functions are defined for a given struct and allow you to encapsulate authorization logic.  You can use
this code within a module that is an Ecto.Schema, but that's not necessary (Ecto isn't required).  The action names are taken from the list
of [actions defined by Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions).

## Installation

To install Pundit, just add an entry to your `mix.exs`:

``` elixir
def deps do
  [
    # ...
    {:pundit, "~> 1.0"}
  ]
end
```

(Check [Hex](https://hex.pm/packages/pundit) to make sure you're using an up-to-date version number.)

## Usage
Here's a basic example, starting with a simple struct for a `Post`.  A module named `Post.Policy` should be created to
encapsulate all of the access methods (`Pundit` will automatically look for the `<struct module>.Policy` module
to determine the module name to look at for access methods).

To declare an initial set of access functions (`show?`, `edit?`, `delete?`, etc)
which all return `false` (default safe!), just `use` `Pundit.DefaultPolicy`.  You can then override the functions as needed
with the logic necessary to determine whether a user should be able to perform the given action.  In this example, we only
determine whether a user can `edit?` a post, leaving all other functions (like `delete?`) to return the default of `false`.

```elixir
defmodule Post do
  defstruct [:author, :title, :body, :comments]

  defmodule Policy do
    # This will initialize all the action functions, all of which return false
    # by default. Override them individually to return true when they should,
    # like edit? is overriden below.
    use Pundit.DefaultPolicy

    def edit?(post, user) do
      user.name == post.author
    end
  end
end

post = %Post{author: "Snake Plissken"}
author = %{name: "Snake Plissken"}
# next line is same as Pundit.can?(post, author, :edit?)
# Pundit will just delegate to Post.Policy.edit?(post, user)
if Pundit.edit?(post, author) do
  IO.puts("Can edit!")
end

if Pundit.delete?(post, author) do
  IO.puts("This line should never be called")
end

# raise exception if user should be able to do a thing
Pundit.authorize!(post, author, :edit?)
```

## Scope
You can also provide query scope for a struct (say, if you're using `Ecto.Schema`) for a given user.  For instance,
say our `Post` was an `Ecto` schema.  Our function for scoping all `Post`s to a specific `User` could be to find all
`Post`s that were authored by a user.  For instance:

```elixir
defmodule Post do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  defmodule Policy do
    use Pundit.DefaultPolicy

    def scope(query, user) do
      from post in query,
        where: post.author_id == ^user.id
    end
  end
end

user = MyApp.Repo.get(User, 1)
posts = Pundit.scope(Post, user) |> Repo.all()

query = from p in Post, where: p.comment_count > 10
popular_posts = Pundit.scope(query, user) |> Repo.all()
```

See [the docs](https://hexdocs.pm/pundit) for more examples.

## Running Tests

To run tests:

```shell
$ mix test
```

## Reporting Issues

Please report all issues [on github](https://github.com/bmuller/pundit-elixir/issues).
