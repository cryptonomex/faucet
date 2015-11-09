require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'promise'

class GrapheneApi

    def initialize(ws_rpc, api_name)
        @ws_rpc, @api_name, @api_id = ws_rpc, api_name, 0
        if api_name
            @init_promise = @ws_rpc.call([0, api_name, []]).then { |res| @api_id = res.to_i }
        else
            @init_promise = nil
        end
    end

    def exec(method, params)
        if @init_promise
            @init_promise.then { @ws_rpc.call([@api_id, method, params]) }
        else
            @ws_rpc.call([@api_id, method, params])
        end
    end

end

class WebSocketRpc

    attr_reader :web_socket

    def initialize(ws_server, logger, connection_promise)
        @ws_server = ws_server
        @logger = logger
        @connection_promise = connection_promise
        @current_callback_id = 0
        @callbacks = {}
    end

    def init
        @web_socket = Faye::WebSocket::Client.new(@ws_server)
    end

    def on_connected
        puts "Established connection to '#{@ws_server}'"
        @logger.info "Established connection to '#{@ws_server}'" if @logger
        @connection_promise.fulfill
    end

    def on_error(error)
        puts "Websocket RPC On Error: #{error}"
        @logger.error "Websocket RPC On Error: #{error}" if @logger
        @connection_promise.reject(error)
    end

    def on_message(response)
        #puts "on_message #{response}"
        #@logger.info "on_message #{response}" if @logger
        callback = @callbacks[response['id']]
        if response['error']
            puts "Websocket RPC Error: #{response['error']}"
            @logger.error "Websocket RPC Error: #{response['error']}" if @logger
            callback[:promise].reject(response['error'])
        else
            callback[:promise].fulfill(response['result'])
        end
    end

    def on_close
        @logger.info "Closed connection to '#{@ws_server}'" if @logger
        @connection_promise.reject('closed') if @connection_promise.pending?
    end

    def call(params)
        puts "call: #{params}"
        @logger.info "call: #{params}" if @logger
        callback_id = @current_callback_id += 1
        request = {method: 'call', params: params, id: callback_id}
        promise = Promise.new
        @callbacks[callback_id] = {time: Date.new, promise: promise}
        @web_socket.send(JSON.generate(request))
        return promise
    end

    def login(user, password)
        @connection_promise.then do
            call([1, 'login', [user, password]]).then do |result|
                puts '*** logged in to graphene websocket rpc ***'
                @logger.info '*** logged in to graphene websocket rpc ***' if @logger
            end
        end
    end

    def shutdown
        @web_socket.close
    end

    def get_api(name)
        return GrapheneApi.new(self, name)
    end

end

class GrapheneClient

    class LostConnection < StandardError; end

    attr_reader :accounts

    def initialize(ws_server, logger)
        @ws_server = ws_server
        @logger = logger
        @accounts = []
        @login_promise = nil
    end

    def get_api(name = nil)
        if @login_promise
            @login_promise.then { @web_socket_rpc.get_api(name) }
        else
            promise = Promise.new
            promise.fulfill(@web_socket_rpc.get_api(name))
            promise
        end
    end

    def load_accounts
        get_api(nil).then do |db_api|
            db_api.exec('lookup_accounts', ['', 100]).then do |result|
                result.each { |a| @accounts << a[0] }
            end
        end
    end

    def login
        @login_promise = @web_socket_rpc.login('', '').then do
            @logger.debug('Graphene: web_socket_rpc logged in') if @logger
        end
    end

    def shutdown
        @web_socket_rpc.shutdown
        EM.stop
    end

    def die_gracefully_on_signal
        Signal.trap("INT") { shutdown }
        Signal.trap("TERM") { shutdown }
    end

    def em_run
        reconnect_attempts = 0
        while true
            EM.run do
                @web_socket_rpc.init

                @web_socket_rpc.web_socket.on :open do
                    @web_socket_rpc.on_connected
                    reconnect_attempts = 0
                end

                @web_socket_rpc.web_socket.on :error do |event|
                    @web_socket_rpc.on_error(event)
                end

                @web_socket_rpc.web_socket.on :message do |message|
                    response = JSON.parse(message.data)
                    @web_socket_rpc.on_message(response)
                end

                @web_socket_rpc.web_socket.on :close do
                    @web_socket_rpc.on_close
                    EM.stop
                end
            end
            ExceptionNotifier.notify_exception(LostConnection.new, :data => {connection: @ws_server}) if reconnect_attempts == 0
            reconnect_attempts += 1
            sleep 10
            @logger.info "GrapheneClient - attempt to reconnect #{reconnect_attempts}"
        end
    end

    def run
        connection_promise = Promise.new
        @web_socket_rpc = WebSocketRpc.new(@ws_server, @logger, connection_promise)
        if defined?(PhusionPassenger)
            PhusionPassenger.on_event(:starting_worker_process) do |forked|
                @logger.info "PhusionPassenger starting_worker_process event (forked:#{forked})" if @logger
                if forked && EM.reactor_running?
                    # for passenger, we need to avoid orphaned threads
                    shutdown
                end
                Thread.new {
                    puts "Starting graphene websocket communication event-loop '#{@ws_server}'"
                    @logger.info "Starting graphene websocket communication event-loop '#{@ws_server}'" if @logger
                    em_run
                }
                die_gracefully_on_signal
            end
        else
            # faciliates debugging
            Thread.abort_on_exception = true
            # just spawn a thread and start it up
            Thread.new {
                puts "Starting graphene websocket communication event-loop '#{@ws_server}'"
                @logger.info "Starting graphene websocket communication event-loop '#{@ws_server}'" if @logger
                em_run
            } unless defined?(Thin)
            # Thin is built on EventMachine, doesn't need this thread
        end
        return connection_promise
    end

    def sync_exec(method, params)
        mutex = Mutex.new
        cond = ConditionVariable.new
        res, err = nil, nil
        on_fulfill = Proc.new do |result|
            res = result
            cond.signal
        end
        on_reject = Proc.new do |error|
            err = error
            cond.signal
        end
        get_api().then do |api|
            api.exec(method, params).then(on_fulfill, on_reject)
        end
        mutex.synchronize do
            cond.wait(mutex)
        end
        return [res, err]
    end

    def async_exec(method, params)
        get_api().then do |api|
            api.exec(method, params)
        end
    end

end

if $0 == __FILE__
    puts 'Graphene Websocket API test..'
    g = GrapheneClient.new('ws://localhost:8091', nil)
    thread = g.run
    sleep 0.5
    #g.login
    #wallet_api =
    g.get_api().then do |api|
        promise = api.exec('list_accounts', ['', 100]).then do |result|
            puts "accounts #{result}"
        end
        promise.then do
            api.exec('list_account_balances', ['1.2.15']).then do |result|
                puts "accounts #{result}"
            end
        end
    end
    # g.load_accounts.then do
    #   puts "All accounts: #{g.accounts}"
    #   puts 'press any key to exit..'
    # end
    STDIN.getc
    g.shutdown
    thread.join
end



