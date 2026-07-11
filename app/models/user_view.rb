class UserView < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }

  scope :alphabetically, -> { order(:name) }

  # Applies this view's account/owner filter on top of the user's accessible
  # scope. Returns an ActiveRecord::Relation of Accounts. Empty account_ids and
  # owner_ids arrays are treated as "no filter for that dimension" so a view
  # with only account_ids scopes by account, a view with only owner_ids scopes
  # by owner, and a view with both intersects them.
  def scope_accounts(base_scope)
    base_scope = base_scope.where(id: account_ids) if account_ids.present? && account_ids.any?
    base_scope = base_scope.where(owner_id: owner_ids) if owner_ids.present? && owner_ids.any?
    base_scope
  end

  def empty?
    account_ids.blank? && owner_ids.blank?
  end
end
