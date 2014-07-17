require 'test/unit'
require 'active_record'
require '../lib/load_balancer_adapter'

module Kernel
  alias_method :orig_rand, :rand

  def redefine_rand
    def rand(x)
      1
    end
  end

  def revert_rand
    def rand(x)
      orig_rand
    end
  end
end

class LoadBalancerAdapterTest < ActiveSupport::TestCase
  def test_should_load_balance_across_connections
    ActiveRecord::Base.configurations[:development] = {
        :adapter => 'load_balancer',
        :actual_adapter => 'mysql',
        :encoding => 'utf8',
        :reconnect => true,
        :database => 'information_schema',
        :pool => 3,
        :username => 'root',
        :password => '',
        :hosts => ['127.0.0.1','localhost']
    }

    pool = ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:development])

    # trigger creation of 2 new connections
    assert_equal "127.0.0.1", (first = pool.checkout).instance_eval("@config")[:host]
    assert_equal "localhost", (second = pool.checkout).instance_eval("@config")[:host]
    assert_equal "127.0.0.1", (third = pool.checkout).instance_eval("@config")[:host]
    pool.checkin(first)
    pool.checkin(second)

    # now the existing connections should be picked randomly
    #
    # force checkout to return the 2nd conn, when by default it would have returned the first
    redefine_rand
    assert_equal "localhost", (second = pool.checkout).instance_eval("@config")[:host]
    pool.checkin(second)

  ensure
    revert_rand
  end

end

