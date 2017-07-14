begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # Activate the gem you are reporting the issue against.
  gem "activerecord", "5.1.2"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :products, force: true do |t|
    t.string :name
  end

  create_table :skus, force: true do |t|
    t.integer :product_id
  end

  create_table :bundle_skus, force: true do |t|
    t.integer :sku_id
    t.integer :product_id
  end
end

class Product < ActiveRecord::Base
  has_many :skus
end

class BundleProduct < Product
  has_many :bundle_skus, foreign_key: :product_id
  has_many :skus, through: :bundle_skus
end

class Sku < ActiveRecord::Base
  belongs_to :product
end

class BundleSku < ActiveRecord::Base
  belongs_to :product
end

class BugTest < Minitest::Test
  def test_association_parent_has_many
    Product.new.skus
  end
  def test_association_sti_has_many_through_error
    BundleProduct.new.skus
  end
end
