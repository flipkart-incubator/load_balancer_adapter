
module ActiveRecord
  class Base
    @@last_host = nil

    # Round-robins through the list of :hosts, returning a new connection each time
    def self.load_balancer_connection(config)
      hosts = config[:hosts]
      if Array === hosts
        actual_adapter = config[:actual_adapter]
        raise ":actual_adapter required in config e.g. config[:actual_adapter] => 'mysql'" unless actual_adapter

        require "active_record/connection_adapters/#{actual_adapter}_adapter"

        new_config = config.dup
        new_config[:adapter] = actual_adapter

        unless @@last_host
          @@last_host = hosts[0]
        else
          next_host_index = (hosts.index(@@last_host) + 1) % hosts.length # cycle through hosts
          @@last_host = hosts[next_host_index]
        end
        new_config[:host] = @@last_host
      else
        new_config = config
      end

      return self.send("#{actual_adapter}_connection", new_config) # create the actual connection
    end
  end
end