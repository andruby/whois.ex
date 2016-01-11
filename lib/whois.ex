defmodule Whois do

  require Record

  Record.defrecord :xmlObj, Record.extract(:xmlObj, from_lib: "xmerl/include/xmerl.hrl")

  def servers do
    {xml, _rest} = :xmerl_scan.file("config/whois-server-list.xml")
    :xmerl_xpath.string('/domainList/domain', xml)
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
