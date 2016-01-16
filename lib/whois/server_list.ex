defmodule Whois.DomainList do
  use GenServer
  require Record

  Record.defrecord :xmlObj, Record.extract(:xmlObj, from_lib: "xmerl/include/xmerl.hrl")

  @initial_state %{domains: []}

  def handle_call({:domain_for, hostname}, _from, %{domains: domains} = state) do
    domain = Enum.max_by(domains, fn(domain) ->
      if Regex.match?(~r/\.#{domain.name}$/, hostname) do
        String.length(domain.name)
      else
        0
      end
    end)
    {:reply, domain, state}
  end

  def handle_call({:domains}, _from, %{domains: domains} = state) do
    {:reply, domains, state}
  end

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state, name: {:global, :whois_domain_list})
  end

  def init(state) do
    {:ok, %{state | domains: parse_domains}}
  end

  defp parse_domains do
    {xml, _rest} = :xmerl_scan.file("config/whois-server-list.xml")
    :xmerl_xpath.string('//domain', xml)
    |> Enum.map(&parse_domain/1)
  end

  defp parse_domain(xml_element) do
    name = :xmerl_xpath.string('string(@name)', xml_element) |> getString
    state = :xmerl_xpath.string('string(./state/text())', xml_element) |> getString
    whois_servers = :xmerl_xpath.string('./whoisServer', xml_element)
    |> Enum.map(&parse_server/1)
    %Whois.Domain{name: name, state: state, whois_servers: whois_servers}
  end

  defp parse_server(xml_element) do
    host = :xmerl_xpath.string('string(@host)', xml_element) |> getString
    available_pattern = :xmerl_xpath.string('string(./availablePattern/text())', xml_element) |> getString
    %Whois.WhoisServer{host: host, available_pattern: available_pattern}
  end

  defp getString(xmlObj(type: :string, value: value)), do: List.to_string(value)
end
