# This migration comes from fullcalendar_engine (originally 20131203105320)
class CreateFullcalendarEngineEvents < ActiveRecord::Migration
  def change
    create_table :fullcalendar_engine_events do |t|
      t.string :title
      t.datetime :starttime, :endtime
      t.boolean :all_day, :default => false
      t.text :description
      t.integer :event_series_id

      #audit field
      t.integer :mg_school_id
      t.boolean :is_deleted
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    add_index :fullcalendar_engine_events, :event_series_id
  end
end
