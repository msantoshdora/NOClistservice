defmodule NoclistService.Mocks do
  def mock_noclist_service_apis do
    [
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

            :get,
            "http://0.0.0.0:8888/users",
            _,
            [
              {"X-Request-Checksum",
               c20acb14a3d3339b9e92daebb173e41379f9f2fad4aa6a6326a696bd90c67419}
            ],
            _ ->
              {:ok,
               %HTTPoison.Response{
                 body: ["user1"],
                 headers: [],
                 status_code: 200
               }}
          end
        ]
      }
    ]
  end
end
