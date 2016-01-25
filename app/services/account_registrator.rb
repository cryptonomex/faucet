class AccountRegistrator

    def initialize(user, logger)
        @user = user
        @logger = logger
    end

    def is_cheap_name(account_name)
        return /[0-9-]/ =~ account_name || !(/[aeiouy]/ =~ account_name)
    end

    def get_account_member_status(account)
        return 'lifetime' if account['lifetime_referrer'] == account['id']
        exp = DateTime.parse(account['membership_expiration_date'])
        return exp < DateTime.now ? 'basic' : 'annual'
    end

    def get_account_info(name)
        account = GrapheneCli.instance.exec('get_account', [name])
        if account && account[0] && account[0]['id']
            return {id: account[0]['id'], member_status: get_account_member_status(account[0])}
        end
        return nil
    end

    def register(account_name, owner_key, active_key, memo_key, referrer)
        @logger.info("---- Registering account: '#{account_name}' #{owner_key}/#{active_key} referrer: #{referrer}")

        if get_account_info(account_name)
            @logger.warn("---- Account exists: '#{account_name}' #{get_account_info(account_name)}")
            return {error: {'message' => 'Account exists'}}
        end

        if !is_cheap_name(account_name)
            @logger.warn("---- Attempt to register premium name: '#{account_name}'")
            return {error: {'message' => 'Premium names registration is not supported by this faucet'}}
        end

        registrar_account = Rails.application.config.faucet.registrar_account
        referrer_account = registrar_account
        referrer_percent = 0
        unless referrer.blank?
            refaccount_info = get_account_info(referrer)
            if refaccount_info && (refaccount_info[:member_status] == 'lifetime' || refaccount_info[:member_status] == 'annual')
                referrer_account = referrer
                referrer_percent = Rails.application.config.faucet.referrer_percent
            else
                @logger.warn("---- Referrer '#{referrer}' is not a member")
            end
        end

        res = {}
        result, error = GrapheneCli.instance.exec('register_account', [account_name, owner_key, active_key, registrar_account, referrer_account, referrer_percent, true])
        if error
            @logger.error("!!! register_account error: #{error.inspect}")
            res[:error] = error
        else
            @logger.debug(result.inspect)
            res[:result] = result
            #GrapheneCli.instance.exec('transfer', [registrar_account, account_name, '1000', 'QBITS', 'Welcome to OpenLedger. Read more about Qbits under asset', true])
        end
        return res
    end


end
