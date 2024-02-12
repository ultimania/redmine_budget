class CreateBudgets < ActiveRecord::Migration[6.1]
  def change
    create_table :budgets do |t|
      t.string :question
      t.integer :yes
      t.integer :no
    end
  end
end
