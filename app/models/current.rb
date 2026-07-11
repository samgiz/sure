class Current < ActiveSupport::CurrentAttributes
  attribute :user_agent, :ip_address

  attribute :session

  # The user-selected view that filters which accounts are shown in dashboard /
  # sidebar / balance sheet contexts. Nil = "no filter, show everything the
  # user can access." Set by ApplicationController from session[:active_view_id]
  # on every request.
  attribute :active_view

  delegate :family, to: :user, allow_nil: true

  def user
    impersonated_user || session&.user
  end

  def impersonated_user
    session&.active_impersonator_session&.impersonated
  end

  def true_user
    session&.user
  end

  def accessible_accounts
    return family&.accounts unless user
    user.accessible_accounts
  end

  def finance_accounts
    return family&.accounts unless user
    user.finance_accounts
  end

  def accessible_entries
    return family&.entries unless user
    family.entries.joins(:account).merge(Account.accessible_by(user))
  end
end
