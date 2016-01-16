defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  setup_all do
    {:ok, _pid} = Whois.ServerList.start_link()
    :ok
  end

  test "servers" do
    servers = Whois.servers
    first = servers |> List.first
    assert length(servers) == 7098
    assert first.name == "aaa"
    assert first.state == "ACTIVE"
  end

  test "servers contains co.uk" do
    servers = Whois.servers
    assert Enum.find(servers, fn(server) -> server.name == "co.uk" end)
  end

  test "google.com is unavailable" do
    refute Whois.available?("google.com")
  end

  test "efjnwejrnfgrfsd.com is available" do
    assert Whois.available?("efjnwejrnfgrfsd.com")
  end

  test "server_for(jeff.co.uk) returns co.uk" do
    assert Whois.server_for("jeff.co.uk").name == "co.uk"
  end

  test "server_for(jeffco.uk) returns uk" do
    assert Whois.server_for("jeffco.uk").name == "uk"
  end

  test "server_for(youtu.be) returns be" do
    assert Whois.server_for("youtu.be").name == "be"
  end
end
