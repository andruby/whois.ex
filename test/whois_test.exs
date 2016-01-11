defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  test "servers" do
    servers = Whois.servers
    first = List.first(servers)
    assert length(servers) == 1090
    assert first.name == "aaa"
    assert first.state == "ACTIVE"
  end
end
