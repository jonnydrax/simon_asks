class AddStateFieldToQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :simon_asks_question_answers, :accepted, :boolean, default: false
  end
end
