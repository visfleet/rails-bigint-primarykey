require 'minitest/autorun'
require 'bigint_pk'
require 'byebug'
require 'active_record'

BigintPk.enabled = true

class MigrationTest < Minitest::Test
  def setup
    super
    ActiveRecord::Base.establish_connection(adapter: "mysql2", database: "bigint_test")
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  def teardown
    super
    ActiveRecord::Base.connection.drop_table("foo") rescue nil
  end

  def test_creating_a_table_use_bigint_as_primary_key
    connection = ActiveRecord::Base.connection
    connection.create_table('foo')
    columns = connection.columns(:foo)
    assert_equal ['id'], columns.map(&:name)
    assert_equal [:integer], columns.map(&:type)
    assert_equal ['bigint(20)'], columns.map(&:sql_type)
    assert_equal [8], columns.map(&:limit)
  end

  def test_creating_a_reference_column_uses_bigint
    connection = ActiveRecord::Base.connection
    connection.create_table('foo') do |td|
      td.references :post
    end
    columns = connection.columns(:foo)
    assert_equal ['id', 'post_id'], columns.map(&:name)
    assert_equal [:integer, :integer], columns.map(&:type)
    assert_equal ['bigint(20)', 'bigint(20)'], columns.map(&:sql_type)
    assert_equal [8, 8], columns.map(&:limit)
  end
end
