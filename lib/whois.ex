defmodule Whois do
  def available?(domain) do
    server = server_for(domain)
    # TODO ask the server for a whois
  end

  def domain_for(hostname) do
    GenServer.call({:global, :whois_domain_list}, {:domain_for, hostname})
  end

  def domains do
    GenServer.call({:global, :whois_domain_list}, {:domains})
  end
end
