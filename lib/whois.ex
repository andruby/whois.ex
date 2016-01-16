defmodule Whois do
  def available?(domain) do
    server = server_for(domain)
    # TODO ask the server for a whois
  end

  def server_for(domain) do
    GenServer.call({:global, :whois_server_list}, {:server_for, domain})
  end

  def servers do
    GenServer.call({:global, :whois_server_list}, {:servers})
  end
end
