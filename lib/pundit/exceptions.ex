defmodule Pundit.NotDefinedError do
  @moduledoc """
  Exception raised when a module doesn't implement a necessary access function.
  """
  defexception message: "The function you are trying to call is not defined."
end

defmodule Pundit.NotAuthorizedError do
  @moduledoc """
  Exception raised when a user attempts to perform an action they're not authorized to perform.
  """
  defexception message: "The user is not authorized to perform the given action."
end
