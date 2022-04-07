defmodule Pundit do
  @moduledoc """
  Pundit provides a set of helpers which guide you in leveraging regular Elixir methods to
  build a simple authorization system.  This library is based heavily on Jonas Nicklas'
  [Ruby project of the same name](https://github.com/varvet/pundit).

  Simple Elixir functions are defined for a given struct and allow you to encapsulate authentication logic.  You can use
  this code within a module that is an `Ecto.Schema`, but that's not necessary.  The action names are taken from the list
  of [actions defined by Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions).

  ## Examples
  Here's a basic example, starting with a simple struct for a `Post`.  A module named `Post.Policy` should be created to
  encapsulate all of the access methods (`Pundit` will automatically look for the `<struct module>.Policy` module
  to determine the module name to look at for access methods).

  To declare an initial set of access functions (`show?`, `edit?`, `delete?`, etc)
  which all return `false` (default safe!), just `use` `Pundit.DefaultPolicy`.  You can then override the functions as needed
  with the logic necessary to determine whether a user should be able to perform the given action.  In this example, we only
  determine whether a user can `edit?` a post, leaving all other functions (like `delete?`) to return the default of `false`.

      defmodule Post do
        defstruct [:author, :title, :body, :comments]

        defmodule Policy do
          # This will initialize all the functions listed below, that all return false
          # by default. Override them individually to return true when they should.
          use Pundit.DefaultPolicy

          def edit?(post, user) do
            user.name == post.author
          end
        end
      end

      post = %Post{author: "Snake Plissken"}
      author = %{name: "Snake Plissken"}
      # next line is same as Pundit.can?(post, author, :edit?)
      if Pundit.edit?(post, author) do
        IO.puts("Can edit!")
      end

      if Pundit.delete?(post, author) do
        IO.puts("This line should never be called")
      end

      # raise exception if user should be able to do a thing
      Pundit.authorize!(post, author, :edit?)

  ## Scope
  You can also provide query scope for a struct (say, if you're using `Ecto.Schema`) for a given user.  For instance,
  say our `Post` was an `Ecto` schema.  Our function for scoping all `Post`s to a specific `User` could be to find all
  `Post`s that were authored by a user.  For instance:

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
  """

  alias Pundit.{NotAuthorizedError, NotDefinedError}

  @doc """
  Returns true only if the user should be allowed to see an index (list) of the given things.
  """
  @spec index?(thing :: struct() | module(), user :: term()) :: boolean()
  def index?(thing, user) do
    can?(thing, user, :index?)
  end

  @doc """
  Returns true only if the user should be allowed to see the given thing.
  """
  @spec show?(thing :: struct() | module(), user :: term()) :: boolean()
  def show?(thing, user) do
    can?(thing, user, :show?)
  end

  @doc """
  Returns true only if the user should be allowed to create a new kind of thing.
  """
  @spec create?(thing :: struct() | module(), user :: term()) :: boolean()
  def create?(thing, user) do
    can?(thing, user, :create?)
  end

  @doc """
  Returns true only if the user should be allowed to see a form to create a new thing.

  See [the page on Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions) for more details on the
  purpose of this action.
  """
  @spec new?(thing :: struct() | module(), user :: term()) :: boolean()
  def new?(thing, user) do
    can?(thing, user, :new?)
  end

  @doc """
  Returns true only if the user should be allowed to update the attributes of a thing.
  """
  @spec update?(thing :: struct() | module(), user :: term()) :: boolean()
  def update?(thing, user) do
    can?(thing, user, :update?)
  end

  @doc """
  Returns true only if the user should be allowed to see a form for updating the thing.

  See [the page on Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions) for more details on the
  purpose of this action.
  """
  @spec edit?(thing :: struct() | module(), user :: term()) :: boolean()
  def edit?(thing, user) do
    can?(thing, user, :edit?)
  end

  @doc """
  Returns true only if the user should be allowed to delete a thing.
  """
  @spec delete?(thing :: struct() | module(), user :: term()) :: boolean()
  def delete?(thing, user) do
    can?(thing, user, :delete?)
  end

  @doc """
  Raise a `Pundit.NotAuthorizedError` exception unless the user can perform the action on the thing.
  """
  @spec authorize!(thing :: struct() | module(), user :: term(), action :: atom()) :: boolean()
  def authorize!(thing, user, action) do
    case authorize(thing, user, action) do
      {:ok} ->
        true

      {:error, msg} ->
        raise NotAuthorizedError, message: msg
    end
  end

  @doc """
  Return a tuple based on whether a user can perform the action on the thing.

  Returns `{:ok}` if a user can perform the action, or `{:error, message}` if not.
  """
  @spec authorize(thing :: struct() | module(), user :: term(), action :: atom()) ::
          {:ok} | {:error, String.t()}
  def authorize(thing, user, action) do
    if can?(thing, user, action) do
      {:ok}
    else
      {:error, "User #{inspect(user)} cannot #{action} #{inspect(thing)}"}
    end
  end

  @doc """
  Determine if a use can perform an action on a given thing.

  This will attempt to call a function with the same name as the action on the policy
  module of the given thing.  For instance:

      Pundit.can?(post, user, :edit?)

  is the same as:

      Post.Policy.edit?(post, user)

  """
  @spec can?(thing :: struct() | module(), user :: term(), action :: atom()) :: boolean()
  def can?(thing, user, action) do
    module = thing |> get_module() |> Module.concat(Policy)

    with {:module, _module} <- Code.ensure_compiled(module),
         true <- Kernel.function_exported?(module, action, 2) do
      apply(module, action, [thing, user])
    else
      _ -> raise NotDefinedError, message: "#{module}.#{action} is not defined."
    end
  end

  @doc """
  Scope a `Ecto.Query` or `Ecto.Schema` to a given user.

  This will call the function `scope` on the policy module of the given thing.  For instance:

      Pundit.scope(Post, user)

  is the same as:

      Post.Policy.scope(Post, user)

  Here's an example with a `Ecto.Query`:

      query = from post in Post, where: post.comments > 10
      # This call...
      Pundit.scope(query, user)
      # Is the same as...
      Post.Policy.scope(query, user)

  This is just helpful shorthand.
  """
  @spec scope(schema :: module() | Ecto.Query.t(), user :: term()) :: Ecto.Query.t()
  def scope(%{__struct__: Ecto.Query, from: %{source: {_, schema}}} = query, user) do
    schema
    |> Module.concat(Policy)
    |> do_scope(query, user)
  end

  def scope(schema, user) when is_atom(schema) do
    schema
    |> Module.concat(Policy)
    |> do_scope(schema, user)
  end

  defp do_scope(module, query, user) do
    if Kernel.function_exported?(module, :scope, 2) do
      module.scope(query, user)
    else
      raise NotDefinedError, message: "Function scope/2 not defined on #{module}"
    end
  end

  defp get_module(thing) do
    cond do
      is_atom(thing) and Kernel.function_exported?(thing, :__info__, 1) ->
        thing

      is_map(thing) and Map.has_key?(thing, :__struct__) ->
        thing.__struct__

      true ->
        raise ArgumentError, message: "The first parameter should be a module or a struct"
    end
  end
end
