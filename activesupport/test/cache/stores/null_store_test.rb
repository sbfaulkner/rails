# frozen_string_literal: true

require_relative "../../abstract_unit"
require "active_support/cache"
require_relative "../behaviors"

class NullStoreTest < ActiveSupport::TestCase
  def setup
    @cache = ActiveSupport::Cache.lookup_store(:null_store)
    @namespace = "test-#{Random.rand(16**32).to_s(16)}"
    @namespaced_cache = ActiveSupport::Cache.lookup_store(:null_store, namespace: @namespace)
  end

  def test_clear
    @cache.write("name", "value")
    @cache.clear
    assert_nil @cache.read("name")
  end

  def test_cleanup
    @cache.write("name", "value")
    @cache.cleanup
    assert_nil @cache.read("name")
  end

  def test_write
    assert_equal true, @cache.write("name", "value")
  end

  def test_read
    @cache.write("name", "value")
    assert_nil @cache.read("name")
  end

  def test_delete
    @cache.write("name", "value")
    assert_equal false, @cache.delete("name")
  end

  def test_increment
    @cache.write("name", 1, raw: true)
    assert_nil @cache.increment("name")
  end

  def test_decrement
    @cache.write("name", 1, raw: true)
    assert_nil @cache.increment("name")
  end

  def test_delete_matched
    @cache.write("name", "value")
    @cache.delete_matched(/name/)
    assert_nil @cache.read("name")
  end

  def test_local_store_strategy
    @cache.with_local_cache do
      @cache.write("name", "value")
      assert_equal "value", @cache.read("name")
      @cache.delete("name")
      assert_nil @cache.read("name")
      @cache.write("name", "value")
    end
    assert_nil @cache.read("name")
  end

  def test_namespaced_local_store_strategy
    @namespaced_cache.with_local_cache do
      @namespaced_cache.write("name", "value")
      assert_equal "value", @namespaced_cache.read("name")
      @namespaced_cache.delete("name")
      assert_nil @namespaced_cache.read("name")
      @namespaced_cache.write("name", "value")
    end
    assert_nil @namespaced_cache.read("name")
  end

  def test_local_store_repeated_reads
    @cache.with_local_cache do
      @cache.read("foo")
      assert_nil @cache.read("foo")

      @cache.read_multi("foo", "bar")
      assert_equal({ "foo" => nil, "bar" => nil }, @cache.read_multi("foo", "bar"))
    end
  end

  def test_namespaced_local_store_repeated_reads
    @namespaced_cache.with_local_cache do
      @namespaced_cache.read("foo")
      assert_nil @namespaced_cache.read("foo")

      @namespaced_cache.read_multi("foo", "bar")
      assert_equal({ "foo" => nil, "bar" => nil }, @namespaced_cache.read_multi("foo", "bar"))
    end
  end
end
