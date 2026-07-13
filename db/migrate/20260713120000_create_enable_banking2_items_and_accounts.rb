class CreateEnableBanking2ItemsAndAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :enable_banking2_items, id: :uuid do |t|
      t.uuid :family_id, null: false
      t.string :name
      t.string :institution_id
      t.string :institution_name
      t.string :institution_domain
      t.string :institution_url
      t.string :institution_color
      t.string :status, default: "good"
      t.boolean :scheduled_for_deletion, default: false
      t.boolean :pending_account_setup, default: false
      t.date :sync_start_date
      t.jsonb :raw_payload
      t.jsonb :raw_institution_payload
      t.string :country_code
      t.string :application_id
      t.text :client_certificate
      t.string :session_id
      t.datetime :session_expires_at
      t.string :aspsp_name
      t.string :aspsp_id
      t.string :authorization_id
      t.jsonb :aspsp_required_psu_headers, default: []
      t.integer :aspsp_maximum_consent_validity
      t.string :aspsp_auth_approach
      t.jsonb :aspsp_psu_types, default: []
      t.string :last_psu_ip
      t.string :psu_type

      t.timestamps
    end

    add_index :enable_banking2_items, :family_id
    add_index :enable_banking2_items, :status

    create_table :enable_banking2_accounts, id: :uuid do |t|
      t.uuid :enable_banking2_item_id, null: false
      t.string :name
      t.string :account_id
      t.string :currency
      t.decimal :current_balance, precision: 19, scale: 4
      t.string :account_status
      t.string :account_type
      t.string :provider
      t.string :iban
      t.string :uid
      t.jsonb :institution_metadata
      t.jsonb :raw_payload
      t.jsonb :raw_transactions_payload
      t.string :product
      t.decimal :credit_limit, precision: 19, scale: 4
      t.jsonb :identification_hashes, default: []

      t.timestamps
    end

    add_index :enable_banking2_accounts, :account_id
    add_index :enable_banking2_accounts, :enable_banking2_item_id
    add_index :enable_banking2_accounts, :identification_hashes, using: :gin
  end
end
