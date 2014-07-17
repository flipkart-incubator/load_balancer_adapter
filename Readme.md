# load_balancer_adapter

*[NOTE: Compatible with ActiveRecord 3.1.x only.]*

Load balances connections across multiple database hosts.

The adapter cycles through hosts, creating a connection to a new host each time.

The gem also patches ActiveRecord's ConnectionPool to return a random connection from it's available connections
instead of the first one, since in a single-threaded server the same connection would get checked out and checked-in repeatedly.

## Usage

```ruby
    ActiveRecord::Base.configurations[:development] = {
        :adapter => 'load_balancer',        # <-- change the adapter to 'load_balancer'
        :actual_adapter => 'mysql',         # <--- actual_adapter is the underlying adapter you want to use to connect to the database
        :hosts => ['127.0.0.1','localhost'] # <--- array of database host names
        :encoding => 'utf8',
        :reconnect => true,
        :database => 'information_schema',
        :pool => 2,
        :username => 'root',
        :password => '',
    }

    pool = ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:development])

    first_conn = pool.checkout
    puts first_conn.instance_eval("@config")[:host]  # <--- prints "127.0.0.1"

    second_conn = pool.checkout
    puts second_conn.instance_eval("@config")[:host]  # <--- prints "localhost"
```

