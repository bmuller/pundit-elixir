defmodule Pundit.DefaultPolicy do
  @moduledoc """
  Default access policies for a given type.

  All of the functions here are named for actions in a [Phoenix controller](https://hexdocs.pm/phoenix/controllers.html#actions).

  If you `use` this module, then default implementations will be added in your module that all 
  return `false` by default (default safe, nothing is permitted).  All are overrideable.
  """

  @doc """
  Returns true only if the user should be allowed to see an index (list) of the given things.
  """
  @callback index?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to see the given thing.
  """
  @callback show?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to create a new kind of thing.
  """
  @callback create?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to see a form to create a new thing.

  See [the page on Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions) for more details on the
  purpose of this action. 
  """
  @callback new?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to update the attributes of a thing.
  """
  @callback update?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to see a form for updating the thing.

  See [the page on Phoenix controllers](https://hexdocs.pm/phoenix/controllers.html#actions) for more details on the
  purpose of this action. 
  """
  @callback edit?(thing :: struct() | module(), user :: term()) :: boolean()

  @doc """
  Returns true only if the user should be allowed to delete a thing.
  """
  @callback delete?(thing :: struct() | module(), user :: term()) :: boolean()

  defmacro __using__(_) do
    quote do
      @behaviour Pundit.DefaultPolicy

      def index?(_thing, _user), do: false
      def show?(_thing, _user), do: false
      def create?(_thing, _user), do: false
      def new?(_thing, _user), do: false
      def update?(_thing, _user), do: false
      def edit?(_thing, _user), do: false
      def delete?(_thing, _user), do: false

      defoverridable index?: 2,
                     show?: 2,
                     create?: 2,
                     new?: 2,
                     update?: 2,
                     edit?: 2,
                     delete?: 2
    end
  end
end
