class CreateOrigSchema < ActiveRecord::Migration

    def change

        create_table 'assets' do |t|
            t.string 'objectid'
            t.string 'symbol'
            t.string 'name'
            t.string 'description'
            t.integer 'precision'
            t.datetime 'created_at'
            t.datetime 'updated_at'
        end

        add_index 'assets', ['objectid'], name: 'index_assets_on_objectid', unique: true
        add_index 'assets', ['symbol'], name: 'index_assets_on_symbol', unique: true

        create_table 'bts_accounts' do |t|
            t.integer 'user_id'
            t.string 'name'
            t.string 'objectid'
            t.string 'owner_key'
            t.string 'active_key'
            t.string 'memo_key'
            t.string 'referrer'
            t.string 'refcode'
            t.string 'remote_ip'
            t.datetime 'created_at'
            t.datetime 'updated_at'
        end

        add_index 'bts_accounts', ['name'], name: 'index_bts_accounts_on_key', unique: true
        add_index 'bts_accounts', ['objectid'], name: 'index_bts_accounts_on_objectid', unique: true
        add_index 'bts_accounts', ['user_id'], name: 'index_bts_accounts_on_user_id'

        create_table 'identities' do |t|
            t.integer 'user_id'
            t.string 'provider'
            t.string 'uid'
            t.string 'email'
            t.datetime 'created_at'
            t.datetime 'updated_at'
        end

        add_index 'identities', ['provider', 'uid'], name: 'index_identities_on_provider_and_uid', unique: true
        add_index 'identities', ['user_id'], name: 'index_identities_on_user_id'

        create_table 'referral_codes' do |t|
            t.integer 'user_id'
            t.integer 'asset_id'
            t.string 'code'
            t.string 'funded_by'
            t.integer 'amount', limit: 8
            t.datetime 'expires_at'
            t.string 'prerequisites'
            t.datetime 'redeemed_at'
            t.datetime 'created_at'
            t.datetime 'updated_at'
            t.string 'state'
            t.string 'send_to'
            t.string 'login_hash'
        end

        add_index 'referral_codes', ['asset_id'], name: 'index_referral_codes_on_asset_id'
        add_index 'referral_codes', ['code'], name: 'index_referral_codes_on_code', unique: true

        create_table 'user_actions' do |t|
            t.integer 'widget_id'
            t.string 'uid'
            t.string 'action', limit: 16
            t.string 'value'
            t.string 'ip', limit: 48
            t.string 'user_agent'
            t.string 'city'
            t.string 'state'
            t.string 'country'
            t.string 'refurl'
            t.string 'channel', limit: 64
            t.string 'referrer', limit: 64
            t.string 'refcode', limit: 64
            t.string 'campaign', limit: 64
            t.integer 'adgroupid'
            t.integer 'adid'
            t.integer 'keywordid'
            t.datetime 'created_at'
        end

        add_index 'user_actions', ['action'], name: 'index_user_actions_on_action'
        add_index 'user_actions', ['campaign'], name: 'index_user_actions_on_campaign'
        add_index 'user_actions', ['channel'], name: 'index_user_actions_on_channel'
        add_index 'user_actions', ['referrer'], name: 'index_user_actions_on_referrer'
        add_index 'user_actions', ['uid'], name: 'index_user_actions_on_uid'
        add_index 'user_actions', ['widget_id'], name: 'index_user_actions_on_widget_id'

        create_table 'users' do |t|
            t.string 'name', default: '', null: false
            t.string 'email', default: ''
            t.string 'encrypted_password', default: '', null: false
            t.string 'reset_password_token'
            t.datetime 'reset_password_sent_at'
            t.datetime 'remember_created_at'
            t.integer 'sign_in_count', default: 0, null: false
            t.datetime 'current_sign_in_at'
            t.datetime 'last_sign_in_at'
            t.string 'current_sign_in_ip'
            t.string 'last_sign_in_ip'
            t.string 'confirmation_token'
            t.datetime 'confirmed_at'
            t.datetime 'confirmation_sent_at'
            t.boolean 'is_admin', default: false
            t.string 'newsletter_subscription'
            t.datetime 'created_at'
            t.datetime 'updated_at'
            t.string 'uid', limit: 32
            t.string 'unconfirmed_email'
            t.boolean 'newsletter_subscribed'
            t.text 'pending_intention'
            t.boolean 'pending_codes'
        end

        add_index 'users', ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
        add_index 'users', ['email'], name: 'index_users_on_email'
        add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
        add_index 'users', ['uid'], name: 'index_users_on_uid'

        create_table 'widgets' do |t|
            t.integer 'user_id'
            t.string 'allowed_domains'
            t.datetime 'created_at'
            t.datetime 'updated_at'
        end

        add_index 'widgets', ['user_id'], name: 'index_widgets_on_user_id'

    end

end