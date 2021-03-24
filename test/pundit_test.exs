defmodule PunditTest do
  use ExUnit.Case
  alias Pundit.{NotAuthorizedError, NotDefinedError}

  describe "When testing permissions of a thing" do
    test "readable things should be showable and indexable" do
      thing = %ReadableThing{}
      assert Pundit.show?(thing, %{})
      assert Pundit.index?(thing, %{})
      refute Pundit.create?(thing, %{})
      refute Pundit.new?(thing, %{})
      refute Pundit.update?(thing, %{})
      refute Pundit.edit?(thing, %{})
      refute Pundit.delete?(thing, %{})
    end

    test "default permissioned things should allow nothing" do
      thing = %DefaultThing{}
      refute Pundit.show?(thing, %{})
      refute Pundit.index?(thing, %{})
      refute Pundit.create?(thing, %{})
      refute Pundit.new?(thing, %{})
      refute Pundit.update?(thing, %{})
      refute Pundit.edit?(thing, %{})
      refute Pundit.delete?(thing, %{})

      thing = DefaultThing
      refute Pundit.show?(thing, %{})
      refute Pundit.index?(thing, %{})
      refute Pundit.create?(thing, %{})
      refute Pundit.new?(thing, %{})
      refute Pundit.update?(thing, %{})
      refute Pundit.edit?(thing, %{})
      refute Pundit.delete?(thing, %{})
    end

    test "providing nil should ArgumentError" do
      assert_raise ArgumentError, fn ->
        refute Pundit.show?(nil, %{})
      end
    end

    test "calling authorize! raises errors when appropriate" do
      assert_raise(NotAuthorizedError, fn ->
        Pundit.authorize!(ReadableThing, %{}, :edit?)
      end)
    end

    test "calling authorize! doesn't raise error when permitted" do
      assert Pundit.authorize!(ReadableThing, %{}, :show?)
    end

    test "calling authorize returns correct result" do
      assert Pundit.authorize(ReadableThing, %{}, :show?) == {:ok}
      assert ReadableThing |> Pundit.authorize(%{}, :edit?) |> elem(0) == :error
    end
  end

  describe "When testing the scope of a thing" do
    test "the correct scope function should be called" do
      assert Pundit.scope(DefaultThing, %{}) == DefaultThing
    end

    test "no scoping should raise an error" do
      assert_raise(NotDefinedError, fn ->
        Pundit.scope(ReadableThing, %{})
      end)
    end
  end
end
