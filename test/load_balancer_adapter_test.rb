require 'test/unit'
require 'active_record'
require '../lib/load_balancer_adapter'

module Kernel
  alias_method :orig_rand, :rand

  def redefine_rand_1
    def rand(x)
      1
    end
  end

  def redefine_rand_0
    def rand(x)
      0
    end
  end

  def revert_rand
    def rand(x)
      orig_rand
    end
  end
end

class LoadBalancerAdapterTest < ActiveSupport::TestCase
  def test_should_select_a_random_host_when_creating_new_connections
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

    redefine_rand_1
    pool = ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:development])
    assert_equal "localhost", (first = pool.checkout).instance_eval("@config")[:host]

    redefine_rand_0
    pool = ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:development])
    assert_equal "127.0.0.1", (second = pool.checkout).instance_eval("@config")[:host]

    pool.checkin(first)
    pool.checkin(second)
  ensure
    revert_rand
  end

  def test_should_select_a_random_connection_when_checking_out_an_existing_one
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

    first = pool.checkout
    second = pool.checkout

    pool.checkin(first)
    pool.checkin(second)

    # now the existing connections should be picked randomly
    #
    # force checkout to return the 2nd conn, when by default it would have returned the first
    redefine_rand_1
    assert_equal second, pool.checkout
    pool.checkin(second)
  ensure
    revert_rand
  end

end

