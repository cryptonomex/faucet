class ReferralCode < ActiveRecord::Base
    belongs_to :asset
    belongs_to :user

    include AASM

    aasm :column => :state do
        state :empty
        state :sent
        state :funded, initial: true
        state :pending
        state :claimed
        state :expired
        state :closed

        event :fund do
            transitions from: :empty, to: :funded
        end

        event :set_sent do
            transitions from: :funded, to: :sent
            # after do
            #     update_pending_codes_status(true)
            # end
        end

        event :close do
            transitions from: [:funded, :sent, :expired], to: :closed
            # after do
            #     update_pending_codes_status(false)
            # end
        end

        event :set_claimed do
            transitions from: :funded, to: :claimed
        end

    end

    EXPIRE_AT = ['1 hour', '2 hours', '6 hours', '12 hours', '24 hours', '2 days', '3 days', '7 days']
    BASE_ASSET_SYMBOL = Rails.env.production? ? :BTS : :CORE
    AVAILABLE_ASSETS = Asset.where(symbol: [BASE_ASSET_SYMBOL, :USD, :CNY, :EUR, :GOLD, :SILVER]).pluck(:symbol, :id)

    validates :code, presence: true
    validates :amount, presence: true, numericality: true
    validates :asset_id, presence: true
    validates :send_to, email: true, on: :update, allow_nil: true
    validates :funded_by, presence: true, on: :update
    #validates :expires_at, presence: true

    #after_create :deliver_email_notification

    # accessors used by api
    def account=(value)
        self.funded_by = value
    end

    def asset_symbol=(value)
        self.asset = Asset.where(symbol: value).first
        self.asset_id = self.asset.id if self.asset
    end

    def asset_amount=(value)
        self.amount = value
    end


    def user_is_receiver?(user)
        send_to == user.email
    end

    # def update_pending_codes_status(status)
    #     user_sent_to = User.includes(:identities).where('identities.email = ? or users.email = ?', send_to, sent_to).references(:identities).uniq.first
    #     if user_sent_to
    #         user_sent_to.assign_attributes(pending_codes: status)
    #         user_sent_to.save if user_sent_to.changed?
    #     end
    # end

    def self.generate_code
        "#{Rails.application.config.faucet.refcode_prefix}-#{SecureRandom.urlsafe_base64(8).upcase}"
    end

    def asset_amount
        (BigDecimal(amount) / BigDecimal(10 ** asset.precision)).to_s
    end

    def mutate_expires_at(expires_at)
        return Time.now unless expires_at.in?(EXPIRED_AT)

        case expires_at
            when '1 hour'
                DateTime.now + 1.hour
            when '2 hours'
                DateTime.now + 2.hours
            when '6 hours'
                DateTime.now + 6.hours
            when '12 hours'
                DateTime.now + 12.hours
            when '24 hours'
                DateTime.now + 24.hours
            when '2 days'
                DateTime.now + 2.days
            when '3 days'
                DateTime.now + 3.days
            when '7 days'
                DateTime.now + 7.days
        end
    end

    def claim(account)
        logger.debug "---- claiming referral code '#{code}' to account '#{account}'"
        if claimed?
            logger.warn "---- referral code '#{code}' is already claimed"
            return {:error => 'already claimed'}
        end
        if !funded?
            logger.warn "---- referral code '#{code}' is not funded"
            return {:error => 'not funded'}
        end
        result, error = GrapheneCli.instance.exec('transfer', [
                Rails.application.config.faucet.registrar_account,
                account, asset_amount, asset.symbol, "#{code} claim", true])
        res = {}
        if error
            logger.error "!!! refcode funding transfer error '#{error['message']}'"
            res[:error] = error['message']
        else
            self.set_claimed
            self.save!
        end
        return res
    end

    private

    def deliver_email_notification
        UserMailer.refcode(send_to, self, '').deliver_now unless send_to.blank?
    end

end
