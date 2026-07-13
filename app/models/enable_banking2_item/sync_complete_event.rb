class EnableBanking2Item::SyncCompleteEvent
  attr_reader :enable_banking2_item

  def initialize(enable_banking2_item)
    @enable_banking2_item = enable_banking2_item
  end

  def broadcast
    enable_banking2_item.reload

    # Update UI with latest account data
    enable_banking2_item.accounts.each do |account|
      account.broadcast_sync_complete
    end

    family = enable_banking2_item.family
    return unless family

    # Update the Enable Banking item view on the Accounts page
    enable_banking2_item.broadcast_replace_to(
      family,
      target: "enable_banking2_item_#{enable_banking2_item.id}",
      partial: "enable_banking2_items/enable_banking2_item",
      locals: { enable_banking2_item: enable_banking2_item }
    )

    # Update the Settings > Providers panel
    enable_banking2_items = family.enable_banking2_items.ordered.includes(:syncs)
    enable_banking2_item.broadcast_replace_to(
      family,
      target: "enable_banking2-providers-panel",
      partial: "settings/providers/enable_banking2_panel",
      locals: { enable_banking2_items: enable_banking2_items, family: family }
    )

    # Let family handle sync notifications
    family.broadcast_sync_complete
  end
end
