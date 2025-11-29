class AddImageStyleToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :image_style, :string
  end
end
