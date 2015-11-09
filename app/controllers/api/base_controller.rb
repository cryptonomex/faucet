module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :set_resource, only: [:destroy, :update]

    skip_before_filter :verify_authenticity_token

    after_filter :set_access_control_headers

    respond_to :json

    def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = "https://#{Rails.application.routes.default_url_options[:host]}"
        if Rails.env.production?
            headers['Access-Control-Allow-Origin'] = '*'
        elsif request.headers['origin']
            headers['Access-Control-Allow-Origin'] = request.headers['origin']
        end
        headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Credentials'] = 'true'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token, Content-Type, Accept'
        headers['Access-Control-Max-Age'] = '1728000'
    end

    def option
      set_access_control_headers
      render text: '', content_type: 'text/plain'
    end

    # Returns the resource from the created instance variable
    # @return [Object]
    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    # Returns the allowed parameters for searching
    # Override this method in each API controller
    # to permit additional parameters to search on
    # @return [Hash]
    def query_params
      {}
    end

    # Returns the allowed parameters for pagination
    # @return [Hash]
    def page_params
      params.permit(:page, :page_size)
    end

    # The resource class based on the controller
    # @return [Class]
    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    # The singular name for the resource class based on the controller
    # @return [String]
    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    # Only allow a trusted parameter "white list" through.
    # If a single resource is loaded for #create or #update,
    # then the controller for the resource must implement
    # the method "#{resource_name}_params" to limit permitted
    # parameters for the individual model.
    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource(resource = nil)
      resource ||= resource_class.find(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end

    # POST /api/{plural_resource_name}
    def create
      set_resource(resource_class.new(resource_params))

      if get_resource.save
        render :show, status: :created
      else
        render json: {error: get_resource.errors}, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => exception
      render json: {error: exception.message}, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotUnique => exception
      render json: {error: "#{resource_name} exists"}, status: :unprocessable_entity
    end

    # DELETE /api/{plural_resource_name}/1
    def destroy
      get_resource.destroy
      head :no_content
    end

    # GET /api/{plural_resource_name}
    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = resource_class.where(query_params)
                      .page(page_params[:page])
                      .per(page_params[:page_size])

      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    # GET /api/{plural_resource_name}/1
    def show
      respond_with get_resource
    end

    # PATCH/PUT /api/{plural_resource_name}/1
    def update
      if get_resource.update(resource_params)
        render :show
      else
        render json: {error: get_resource.errors}, status: :unprocessable_entity
      end
    end


  end
end
