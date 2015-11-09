require 'cgi'

class WidgetsController < ApplicationController
    #before_action :authenticate_user!, except: [:w, :action, :get_current_user]
    skip_before_filter :verify_authenticity_token, only: [:w, :action, :get_current_user]

    def w
        response.headers['Content-type'] = 'text/javascript; charset=utf-8'
        @w = Widget.find(params[:widget_id])
        logger.info "==> widget[#{@w.id}]: request from '#{request.referer}'"
        host = request.port && !(request.port == 80 || request.port == 443) ? "#{request.host}:#{request.port}" : request.host
        @jsonp_url = "//#{host}/widgets/#{@w.id}"
        uri = get_uri_and_check_domain(@w, request.referer)
        return unless uri
        qpms = uri != :blank && uri.query ? CGI::parse(uri.query) : {}
        action = create_user_action(@w, qpms, request, 'page_view', request.referer, params[:ref])
        write_referral_cookie(action.referrer, action.refcode)
    end

    def action
        response.headers['Content-type'] = 'text/javascript; charset=utf-8'
        w = Widget.find(params[:widget_id])
        logger.info "==> widget[#{w.id}]: action '#{params[:name]}'='#{params[:value]}' from '#{request.referer}'"
        uri = get_uri_and_check_domain(w, request.referer)
        if uri
            qpms = CGI::parse(uri.query)
            action = create_user_action(w, qpms, request, params[:name], params[:value])
            response = action.id
        else
            response = 'failed'
        end
        render :json => response.to_json, :callback => params['callback']
    end

    def get_current_user
        response.headers['Content-type'] = 'text/javascript; charset=utf-8'
        #logger.debug "get_current_user:::::: #{current_user}"
        if current_user
            render :json => {id: current_user.id, name: current_user.name}.to_json, :callback => params['callback']
        else
            render :json => false, :callback => params['callback']
        end
    end

    private

    def sanitize_str(str)
        str = str.length() > 252 ? str[0..252] : str
        return str if str =~ /\A[\w\s\d\-\_\.]*\z/
        ActiveRecord::Base::sanitize(str)
    end

    def sanitize_sparam(sp, len=nil)
        return nil if not (sp and sp.length > 0)
        if len
            sanitize_str(sp[0][0..(len-1)])
        else
            sanitize_str(sp[0])
        end
    end

    def sanitize_iparam(sp)
        return nil if not (sp and sp.length > 0)
        sp[0].to_i
    end

    def get_uri_and_check_domain(w, referer)
        if referer.blank?
            return w.allowed_domains.include?('BLANK') ? :blank : nil
        end
        begin
            uri = URI.parse(request.referer)
        rescue URI::InvalidURIError => e
            logger.error "==> can't parse request uri '#{request.referer}'"
            return nil
        end
        unless w.allowed_domains.include?(uri.host) # TODO: split by comma and compare each domain to uri.host
            logger.error "==> widget[#{w.id}]: domain is not allowed '#{uri.host}'"
            return nil
        end
        return uri
    end

    def create_user_action(w, qpms, request, action, value, refurl = nil)
        if !refurl.blank? && refurl.start_with?('lw-')
            lw, platform, version, guid = refurl.split('-')
            action = UserAction.new ({
                    widget_id: w.id,
                    uid: guid,
                    action: 'app_load',
                    value: version,
                    channel: platform
                })
        else
            action = UserAction.new ({
                    widget_id: w.id,
                    uid: @uid,
                    action: sanitize_str(action),
                    value: sanitize_str(value),
                    refurl: sanitize_str(refurl),
                    channel: sanitize_sparam(qpms['channel'], 64),
                    referrer: sanitize_sparam(qpms['r'], 64),
                    refcode: sanitize_sparam(qpms['refcode'], 64),
                    campaign: sanitize_sparam(qpms['campaign'], 64),
                    adgroupid: sanitize_iparam(qpms['adgroupid']),
                    adid: sanitize_iparam(qpms['adid']),
                    keywordid: sanitize_iparam(qpms['keywordid']),
                    ip: sanitize_str(request.remote_ip),
                    user_agent: sanitize_str(request.user_agent)
                })
        end
        action.save
        return action
    end

    def write_referral_cookie(referrer, refcode)
        cookie = {expires: 1.month.from_now, domain: request_domain}
        cookies[:_referrer_] = cookie.merge({value: referrer}) unless referrer.blank?
        cookies[:_refcode_] = cookie.merge({value: refcode}) unless refcode.blank?
    end

end
