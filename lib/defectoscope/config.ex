defmodule Defectoscope.Config do
  @moduledoc """
  Provides configuration for Defectoscope
  """

  @doc """
  Returns whether Defectoscope is enabled or disabled
  """
  @spec enabled?() :: boolean()
  def enabled? do
    Application.get_env(:defectoscope, :enabled, true)
  end

  @doc """
  Returns the application key
  """
  @spec app_key() :: String.t() | nil
  def app_key do
    Application.get_env(:defectoscope, :app_key)
  end

  @doc """
  Returns the backend endpoint url
  """
  @spec endpoint_url() :: String.t()
  def endpoint_url do
    default_url = "https://api.defectoscope.dev/dev/track"
    Application.get_env(:defectoscope, :endpoint, default_url)
  end

  @doc """
  Returns whether debug mode is enabled
  """
  @spec debug_mode_enabled?() :: boolean()
  def debug_mode_enabled? do
    Application.get_env(:defectoscope, :debug, false)
  end

  @doc """
  Returns Req request options
  """
  @spec req_options() :: keyword()
  def req_options do
    Application.get_env(:defectoscope, :req_options, [])
  end

  @current_env Mix.env()

  @doc """
  Returns the current environment
  """
  @spec current_env() :: atom()
  def current_env do
    Application.get_env(:defectoscope, :current_env, @current_env)
  end

  @doc """
  Validates Defectoscope configuration
  """
  @spec validate_config!() :: term()
  def validate_config! do
    if enabled?(), do: validate_enabled_config!()
  end

  # Raises an exception if the :app_key configuration is missing when defectoscope is enabled
  defp validate_enabled_config! do
    unless app_key(), do: raise("Missing :app_key configuration for :defectoscope")
  end
end
