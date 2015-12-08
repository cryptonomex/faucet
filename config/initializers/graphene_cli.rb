require Rails.root.join('lib/graphene/client.rb').to_s

class GrapheneCli
    include Singleton

    connection_string = Rails.application.config.faucet.cli_wallet_connection
    @@client = GrapheneClient.new(connection_string, Rails.logger)
    @@client.run.then(proc {},
        proc do
            if Rails.env.production?
                raise "can't connect to cli wallet on #{connection_string}"
            else
                puts "Warning! can't connect to cli wallet on #{connection_string}"
            end
        end)

    def exec(method, params)
        @@client.sync_exec(method, params)
    end

end
