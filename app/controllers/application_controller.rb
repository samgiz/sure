class ApplicationController < ActionController::Base
  include RestoreLayoutPreferences, Onboardable, Localize, AutoSync, Authentication, Invitable,
          SelfHostable, StoreLocation, Impersonatable, Breadcrumbable,
          FeatureGuardable, Notifiable, SafePagination, AccountAuthorizable,
          PreviewGateable
  include Pundit::Authorization

  include Pagy::Backend

  # Pundit uses current_user by default, but this app uses Current.user
  def pundit_user
    Current.user
  end

  before_action :detect_os
  before_action :set_default_chat
  before_action :set_active_storage_url_options
  before_action :load_active_view

  helper_method :demo_config, :demo_host_match?, :show_demo_warning?,
                :active_view, :user_views_for_picker

  private
    def accept_pending_invitation_for(user)
      return false if user.blank?

      token = session[:pending_invitation_token]
      return false if token.blank?

      invitation = Invitation.pending.find_by(token: token.to_s)
      return false unless invitation
      return false unless invitation.accept_for(user)

      session.delete(:pending_invitation_token)
      true
    end

    def store_pending_invitation_if_valid
      token = params[:invitation].to_s.presence
      return if token.blank?

      invitation = Invitation.pending.find_by(token: token)
      session[:pending_invitation_token] = token if invitation
    end

    def require_admin!
      return if Current.user&.admin?

      respond_to do |format|
        format.html { redirect_to accounts_path, alert: t("shared.require_admin") }
        format.turbo_stream { head :forbidden }
        format.json { head :forbidden }
        format.any { head :forbidden }
      end
    end

    def detect_os
      user_agent = request.user_agent
      @os = case user_agent
      when /Windows/i then "windows"
      when /Macintosh/i then "mac"
      when /Linux/i then "linux"
      when /Android/i then "android"
      when /iPhone|iPad/i then "ios"
      else ""
      end
    end

    # By default, we show the user the last chat they interacted with
    def set_default_chat
      @last_viewed_chat = Current.user&.last_viewed_chat
      @chat = @last_viewed_chat
    end

    def set_active_storage_url_options
      ActiveStorage::Current.url_options = {
        protocol: request.protocol,
        host: request.host,
        port: request.optional_port
      }
    end

    def demo_config
      Rails.application.config_for(:demo)
    rescue RuntimeError, Errno::ENOENT, Psych::SyntaxError
      nil
    end

    def demo_host_match?(demo = demo_config)
      return false unless demo.is_a?(Hash) && demo["hosts"].present?

      demo["hosts"].include?(request.host)
    end

    def show_demo_warning?
      demo_host_match?
    end

    def accessible_accounts
      Current.accessible_accounts
    end
    helper_method :accessible_accounts

    def finance_accounts
      Current.finance_accounts
    end
    helper_method :finance_accounts

    # Reads session[:active_view_id] and populates Current.active_view. Silent
    # no-op when the id is stale or the referenced view was deleted; downstream
    # code treats Current.active_view.nil? as "no filter."
    def load_active_view
      return unless Current.user
      id = session[:active_view_id]
      return if id.blank?
      Current.active_view = Current.user.user_views.find_by(id: id)
      # Clean up the session if the view was deleted since it was activated.
      session.delete(:active_view_id) unless Current.active_view
    end


    def active_view
      Current.active_view
    end

    def user_views_for_picker
      Current.user&.user_views&.alphabetically || UserView.none
    end
end
