defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  setup_all do
    {:ok, _pid} = Whois.DomainList.start_link()
    :ok
  end

  test "domains" do
    domains = Whois.domains
    first = domains |> List.first
    assert length(domains) == 7098
    assert first.name == "aaa"
    assert first.state == "ACTIVE"
  end

  test "domains contains co.uk" do
    domains = Whois.domains
    assert Enum.find(domains, fn(domain) -> domain.name == "co.uk" end)
  end

  test "google.com is unavailable" do
    refute Whois.available?("google.com")
  end

  test "efjnwejrnfgrfsd.com is available" do
    assert Whois.available?("efjnwejrnfgrfsd.com")
  end

  test "domain_for(jeff.co.uk) returns co.uk" do
    assert Whois.domain_for("jeff.co.uk").name == "co.uk"
  end

  test "domain_for(jeffco.uk) returns uk" do
    assert Whois.domain_for("jeffco.uk").name == "uk"
  end

  test "domain_for(youtu.be) returns be" do
    assert Whois.domain_for("youtu.be").name == "be"
  end
end
