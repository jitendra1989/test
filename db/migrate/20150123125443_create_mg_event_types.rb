class CreateMgEventTypes < ActiveRecord::Migration
  def change
    create_table :mg_event_types do |t|
      t.string :name
      t.string :event_color
      
      t.boolean :is_deleted
      t.integer :mg_school_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
