class CreateMgExamApplicationFormData < ActiveRecord::Migration
  def change
    create_table :mg_exam_application_form_data do |t|
      t.integer :mg_time_table_id
      t.integer :mg_batch_id
      t.integer :mg_wing_id
      t.integer :mg_student_id
      t.date :due_date
      t.integer :mg_school_id
      t.boolean :is_deleted
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
