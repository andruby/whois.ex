defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  setup_all do
    {:ok, _pid} = Whois.DomainList.start_link()
    :ok
  end

  @unavailable_hostname "good"
  @availabale_hostname "isxkblhwrariwkqremzl"
  @domains_to_test ~w(com net io org be co.uk de jp com.br uk ru in it fr info cn ir com.au nl eu tv me at us cc mobi is)

  for domain <- @domains_to_test do
    @unavailable "good.#{domain}"
    @available "isxkblhwrariwkqremzl.#{domain}"
    test @unavailable <> " is unavaiable" do
      refute Whois.available?(@unavailable), "Should be unavailable, but is: #{@unavailable}"
    end

    test @available <> " is avaiable" do
      assert Whois.available?(@available), "Should be available, but isnt: #{@available}"
    end
  end

  test "the first domain is abbott" do
    domains = Whois.domains
    first = domains |> List.first
    assert length(domains) == 1179
    assert first.name == "abbott"
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

  test "gent.be is unavailable" do
    refute Whois.available?("gent.be")
  end

  test "efjnwejrnfgrfsd.be is available" do
    assert Whois.available?("efjnwejrnfgrfsd.be")
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
