defmodule Whois do
  def available?(hostname) do
    domain = domain_for(hostname)
    server = domain.whois_servers |> List.first
    {:ok, socket} = :gen_tcp.connect(to_char_list(server.host), 43, [:binary, active: false])
    :ok = :gen_tcp.send(socket, "domain #{hostname}\r\n")
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    # IO.puts(server.available_pattern)
    # IO.puts(msg)
    Regex.match?(Regex.compile!(server.available_pattern, "i"), msg)
  end

  def domain_for(hostname) do
    GenServer.call({:global, :whois_domain_list}, {:domain_for, hostname})
  end

  def domains do
    GenServer.call({:global, :whois_domain_list}, {:domains})
  end
end
