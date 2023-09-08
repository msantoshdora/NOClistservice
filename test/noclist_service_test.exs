defmodule NoclistServiceTest do
  use ExUnit.Case
  import Mock

  describe "test API calls" do
    test "successful api call" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            request: fn
              :get, "http://0.0.0.0:8888/auth", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "",
                   headers: [{"Badsec-Authentication-Token", "12345"}],
                   status_code: 200
                 }}

              :get, "http://0.0.0.0:8888/users", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "user1\nu2",
                   headers: [],
                   status_code: 200
                 }}
            end
          ]
        }
      ]) do
        assert NoclistService.fetch_users() == 0
      end
    end

    test "Failure of get auth token api call" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            request: fn
              :get, "http://0.0.0.0:8888/auth", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "",
                   headers: [{"Badsec-Authentication-Token", "12345"}],
                   status_code: 500
                 }}
            end
          ]
        }
      ]) do
        assert NoclistService.fetch_users() == :failed
      end
    end

    test "Timeout of get auth token api call" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            request: fn
              :get, "http://0.0.0.0:8888/auth", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "",
                   headers: [{"Badsec-Authentication-Token", "12345"}],
                   status_code: 408
                 }}
            end
          ]
        }
      ]) do
        assert NoclistService.fetch_users() == :failed
      end
    end

    test "Failure of Fetch User api call" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            request: fn
              :get, "http://0.0.0.0:8888/auth", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "",
                   headers: [{"Badsec-Authentication-Token", "12345"}],
                   status_code: 200
                 }}

              :get, "http://0.0.0.0:8888/users", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: ["user1"],
                   headers: [],
                   status_code: 500
                 }}
            end
          ]
        }
      ]) do
        assert NoclistService.fetch_users() == :failed
      end
    end

    test "Timeout of Fetch User api call" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            request: fn
              :get, "http://0.0.0.0:8888/auth", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: "",
                   headers: [{"Badsec-Authentication-Token", "12345"}],
                   status_code: 200
                 }}

              :get, "http://0.0.0.0:8888/users", _, _, _ ->
                {:ok,
                 %HTTPoison.Response{
                   body: ["user1"],
                   headers: [],
                   status_code: 408
                 }}
            end
          ]
        }
      ]) do
        assert NoclistService.fetch_users() == :failed
      end
    end
  end
end
