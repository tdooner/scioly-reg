class AddMarkdownFieldsToTournament < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :hosted_by_markdown, :text, :default=>"You can edit this text in _Tournament Settings_ in the [Admin Panel](/user/login)."
    add_column :tournaments, :homepage_markdown, :text, :default=>"You can edit this text in _Tournament Settings_ in the [Admin Panel](/user/login)."
    add_column :tournaments, :title, :string
  end

  def self.down
    remove_column :tournaments, :hosted_by_markdown
    remove_column :tournaments, :homepage_markdown
    remove_column :tournaments, :title
  end
end
