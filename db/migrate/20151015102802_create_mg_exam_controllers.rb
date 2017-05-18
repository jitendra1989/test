class CreateMgExamControllers < ActiveRecord::Migration
  def change
    create_table :mg_exam_controllers do |t|
      t.integer :mg_employee_id
      t.integer :mg_employee_department_id
      t.boolean :is_deleted
      t.integer :mg_school_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
