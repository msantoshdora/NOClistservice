defmodule NoclistService do
  @moduledoc """
   Fetches user list from NoclistService.
   It attempts to fetch user with two retry. If get_user_list is timedout, then it will retry again.
  """

  @doc """
    Fetch NOClist users. It fetches auth token first and then fetches user list
  """
  @spec fetch_users(Integer.t()) :: :failed | {:ok, List.t()}

  def fetch_users(retry_count \\ 0)

  def fetch_users(2) do
    :failed
  end

  def fetch_users(retry_count) do
    auth_url = System.fetch_env!("AUTH_API")

    case get_auth_token(auth_url, 0) do
      {:ok, auth_token} ->
        checksum = Base.encode16(:crypto.hash(:sha256, "#{auth_token}/users"))
        get_user_list(System.fetch_env!("USERS_API"), checksum, retry_count)

      _ ->
        :failed
    end
  end

  defp get_auth_token(_url, 2) do
    :failed
  end

  # Get Auth Token
  defp get_auth_token(url, retry_count) do
    case HTTPoison.request(
           :get,
           url,
           "",
           [],
           recv_timeout: 5_000,
           timeout: 5_000
         ) do
      {:ok, %{status_code: code, body: _resp_body, headers: headers_body}} when code == 200 ->
        auth_token = fetch_auth_token(headers_body)
        {:ok, auth_token}

      _ ->
        get_auth_token(url, retry_count + 1)
    end
  end

  defp get_user_list(_url, _checksum, 2) do
    :failed
  end

  # Get User list
  defp get_user_list(url, checksum, retry_count) do
    case HTTPoison.request(
           :get,
           url,
           "",
           [{"X-Request-Checksum", checksum}],
           recv_timeout: 5_000,
           timeout: 5_000
         ) do
      {:ok, %{status_code: code, body: user_list}} when code in 200..299 ->
        format_result(user_list)
        0
      {:ok, %{status_code: code, body: _user_list}} when code in 400..499 ->
        # to test response code 408
        get_user_list(url, checksum, retry_count + 1)

      _ ->
        fetch_users(retry_count + 1)
    end
  end

  defp fetch_auth_token(headers_body) do
    Enum.find(headers_body, fn tuple ->
      is_tuple(tuple) and elem(tuple, 0) == "Badsec-Authentication-Token"
    end)
    |> elem(1)
  end

  defp format_result(user_list) do
    String.split(user_list, "\n")
    |> Jason.encode!
    |> IO.puts
  end
end
