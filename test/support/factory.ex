defmodule TdSe.Factory do
  @moduledoc """
  An `ExMachina` factory for data quality tests.
  """
  use ExMachina
  # use TdDfLib.TemplateFactory

  def user_factory do
    %{
      id: System.unique_integer([:positive]),
      user_name: sequence("user_name"),
      full_name: sequence("full_name"),
      external_id: sequence("user_external_id"),
      email: sequence("email") <> "@example.com"
    }
  end

  def domain_factory do
    %{
      name: sequence("domain_name"),
      id: System.unique_integer([:positive]),
      external_id: sequence("domain_external_id"),
      updated_at: DateTime.utc_now()
    }
  end
end
