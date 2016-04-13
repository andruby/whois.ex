defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  setup_all do
    {:ok, _pid} = Whois.DomainList.start_link()
    :ok
  end

  defp pmap(collection, fun) do
    me = self
    collection
    |> Enum.map(fn x ->
      spawn_link(fn ->
        send(me, {self, fun.(x)})
      end)
    end)
    |> Enum.map(fn pid ->
      receive do
        {^pid, result} -> result
      end
    end)
  end

  @unavailable_hostname "good"
  @available_hostname "isxkblhwrariwkqremzl"
  @domains_to_test ~w(com net io org be co.uk de jp com.br uk ru in it fr info cn ir com.au nl eu tv me at us cc mobi is)

  test "the list of available domains" do
    unavailable_domains = Whois.domains
    |> Enum.map(fn(d) -> d.name end)
    |> pmap(fn(domain) ->
      hostname = "#{@available_hostname}.#{domain}"
      {Whois.available?(hostname), hostname}
    end)
    |> Enum.filter_map(&elem(&1, 0), &elem(&1, 1))
    assert unavailable_domains == []
  end

  test "the list of unavailable domains" do
    available_domains = Whois.domains
    |> Enum.map(fn(d) -> d.name end)
    |> pmap(fn(domain) ->
      hostname = "#{@unavailable_hostname}.#{domain}"
      {Whois.available?(hostname), hostname}
    end)
    |> Enum.filter_map(&elem(&1, 0), &elem(&1, 1))
    assert available_domains == []
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
