
module ActiveRecord
  module ConnectionAdapters
    class ConnectionPool
      private

      def checkout_existing_connection
        # need to change the following line to checkout a random connection
        # instead of the first, since when running in single-threaded mode
        # only the first connection would get checked-out and checked-in each time
        # ...
        #c = (@connections - @checked_out).first

        avlbl = (@connections - @checked_out)
        c = avlbl[rand(avlbl.length)]
        checkout_and_verify(c)
      end
    end
  end
end