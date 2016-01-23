defmodule Mix.Tasks.UpdateConfig do
  use Mix.Task
  require Record
  Record.defrecord :xmlObj, Record.extract(:xmlObj, from_lib: "xmerl/include/xmerl.hrl")

  @server_list_url 'http://rawgit.com/whois-server-list/whois-server-list/master/whois-server-list.xml'

  @shortdoc "Download and process server configuration"
  def run(_args) do
    Application.ensure_all_started :inets

    json = parse_domains
    |> filter_domains_without_servers
    |> Poison.encode!(pretty: true)
    Mix.shell.info "Writing JSON"
    File.write!(Application.get_env(:whois, :domains_file), json)
  end

  defp filter_domains_without_servers(domains) do
    Enum.reject(domains, fn(domain) ->
      domain.whois_servers == []
    end)
  end

  defp download_xml do
    Application.ensure_all_started :inets

    Mix.shell.info "Downloading server list from Github"
    {:ok, resp} = :httpc.request(:get, {@server_list_url, []}, [], [body_format: :string])
    {{_, 200, 'OK'}, _headers, body} = resp
    body
  end

  defp parse_domains do
    {xml, _rest} = download_xml
    # |> to_char_list
    |> :xmerl_scan.string
    Mix.shell.info "Parsing XML"
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
