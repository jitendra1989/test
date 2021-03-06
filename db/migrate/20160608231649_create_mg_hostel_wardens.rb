class CreateMgHostelWardens < ActiveRecord::Migration
  def change
    create_table :mg_hostel_wardens do |t|
      t.integer :mg_hostel_details_id
      t.integer :mg_employee_department_id
      t.integer :mg_employee_id
      t.string :user_name
      t.integer :mg_user_id
      t.integer :created_by
      t.integer :updated_by
      t.boolean :is_deleted
      t.integer :mg_school_id

      t.timestamps
    end
  end
end
