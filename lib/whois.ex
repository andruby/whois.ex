defmodule Whois do
  def available?(hostname) do
    domain = domain_for(hostname)
    server = domain.whois_servers |> List.first
    {:ok, socket} = :gen_tcp.connect(to_char_list(server.host), 43, [:binary, active: false])
    :ok = :gen_tcp.send(socket, "domain #{hostname}\r\n")
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    # IO.puts(msg)
    # IO.inspect Regex.run(~r/^.*\Q#{hostname}\E.*$/mi, msg)
    [line_with_domain] = Regex.run(~r/^.*\Q#{hostname}\E.*$/mi, msg)
    # IO.puts(server.available_pattern)
    # IO.puts(line_with_domain)
    Regex.match?(Regex.compile!(server.available_pattern, "i"), line_with_domain)
  end

  def domain_for(hostname) do
    GenServer.call({:global, :whois_domain_list}, {:domain_for, hostname})
  end

  def domains do
    GenServer.call({:global, :whois_domain_list}, {:domains})
  end
end
