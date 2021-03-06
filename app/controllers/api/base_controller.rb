# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Pundit

    after_action :verify_authorized, unless: :skip_pundit?
    after_action :verify_policy_scoped, only: %i[index], unless: :skip_pundit?

    rescue_from StandardError,                with: :internal_server_error
    rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def skip_pundit?
      devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
    end

    def user_not_authorized(exception)
      render json: {
        error: "Unauthorized #{exception.policy.class.to_s.underscore.camelize}.#{exception.query}"
      }, status: :unauthorized
    end

    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end

    def internal_server_error(exception)
      if Rails.env.development?
        response = { type: exception.class.to_s, message: exception.message, backtrace: exception.backtrace }
      else
        response = { error: 'Internal Server Error' }
      end
      render json: response, status: :internal_server_error
    end
  end
end
