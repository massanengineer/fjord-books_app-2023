# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: %i[postal_code address profile])
  end

  def after_sign_out_path_for
    new_user_session_path # ログアウト後の遷移先を指定
  end
end
