ExUnit.start()

defmodule ReadableThing do
  defstruct prop: "value"
end

defmodule ReadableThing.Policy do
  use Pundit.DefaultPolicy

  def show?(_thing, _user) do
    true
  end

  def index?(_thing, _user) do
    true
  end
end

defmodule DefaultThing do
  defstruct prop: "something"
end

defmodule DefaultThing.Policy do
  use Pundit.DefaultPolicy

  def scope(thing, _user) do
    thing
  end
end
