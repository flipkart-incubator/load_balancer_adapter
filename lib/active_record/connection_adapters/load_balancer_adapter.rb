
module ActiveRecord
  class Base

    # Round-robins through the list of :hosts, returning a new connection each time
    def self.load_balancer_connection(config)
      hosts = config[:hosts]
      if Array === hosts
        actual_adapter = config[:actual_adapter]
        raise ":actual_adapter required in config e.g. config[:actual_adapter] => 'mysql'" unless actual_adapter

        require "active_record/connection_adapters/#{actual_adapter}_adapter"

        new_config = config.dup
        new_config[:adapter] = actual_adapter
        new_config[:host] = hosts[rand(hosts.length)]  # pick a host randomly
      else
        new_config = config
      end

      return self.send("#{actual_adapter}_connection", new_config) # create the actual connection
    end
  end
end