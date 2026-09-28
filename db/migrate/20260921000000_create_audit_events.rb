class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.references :actor, foreign_key: {to_table: :users}
      t.references :target_user, foreign_key: {to_table: :users}
      t.references :subject, polymorphic: true
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :audit_events, :action
    add_index :audit_events, :created_at
  end
end