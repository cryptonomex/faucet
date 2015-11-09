class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_action :assign_uid

    def request_domain
        if Rails.env.production?
            host = URI.parse(request.original_url).host
            host = $1 if host =~ /(\w+\.\w+)\z/
            return host
        else
            nil
        end
    end

    private

    def assign_uid
        if cookies[:_uid_]
            @uid = cookies[:_uid_]
        else
            @uid = SecureRandom.urlsafe_base64(16)
            cookies[:_uid_] = {
                value: @uid,
                expires: 10.years.from_now,
                domain: request_domain()
            }
        end
        # if current_user && current_user.uid != @uid
        #     current_user.update_attribute(:uid, @uid)
        # end
    end


end
