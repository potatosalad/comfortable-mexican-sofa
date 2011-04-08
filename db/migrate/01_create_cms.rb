class CreateCms < ActiveRecord::Migration
  
  def self.up
    # -- Sites --------------------------------------------------------------
    create_table :jangle_sites do |t|
      t.string :label
      t.string :hostname
    end
    add_index :jangle_sites, :hostname
    
    # -- Layouts ------------------------------------------------------------
    create_table :jangle_layouts do |t|
      t.integer :jangle_site_id
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label
      t.string  :slug
      t.text    :content
      t.text    :css
      t.text    :js
      t.integer :position, :null => false, :default => 0
      t.timestamps
    end
    add_index :jangle_layouts, [:parent_id, :position]
    add_index :jangle_layouts, [:jangle_site_id, :slug], :unique => true
    
    # -- Pages --------------------------------------------------------------
    create_table :jangle_pages do |t|
      t.integer :jangle_site_id
      t.integer :jangle_layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label
      t.string  :slug
      t.string  :full_path
      t.text    :content
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.boolean :is_published,    :null => false, :default => true
      t.timestamps
    end
    add_index :jangle_pages, [:jangle_site_id, :full_path]
    add_index :jangle_pages, [:parent_id, :position]
    
    # -- Page Blocks --------------------------------------------------------
    create_table :jangle_blocks do |t|
      t.integer   :jangle_page_id
      t.string    :label
      t.text      :content
      t.timestamps
    end
    add_index :jangle_blocks, [:jangle_page_id, :label]
    
    # -- Snippets -----------------------------------------------------------
    create_table :jangle_snippets do |t|
      t.integer :jangle_site_id
      t.string  :label
      t.string  :slug
      t.text    :content
      t.timestamps
    end
    add_index :jangle_snippets, [:jangle_site_id, :slug], :unique => true
    
    # -- Assets -------------------------------------------------------------
    create_table :jangle_uploads do |t|
      t.integer :jangle_site_id
      t.string  :file_file_name
      t.string  :file_content_type
      t.integer :file_file_size
      t.timestamps
    end
    add_index :jangle_uploads, [:jangle_site_id, :file_file_name]
  end
  
  def self.down
    drop_table :jangle_sites
    drop_table :jangle_layouts
    drop_table :jangle_pages
    drop_table :jangle_snippets
    drop_table :jangle_blocks
    drop_table :jangle_uploads
  end
end
