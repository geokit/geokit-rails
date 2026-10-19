require 'test_helper'
# Defines the top-level ::Mysql2 module, which must not be mistaken for the
# Geokit adapter of the same name.
require 'mysql2'

class AdapterResolutionTest < GeokitTestCase
  def test_mysql2_adapter
    adapter = finder_adapter_for('Mysql2')
    assert_instance_of Geokit::Adapters::Mysql2, adapter
  end

  # Database gems can define a top-level class named like an adapter, as the
  # trilogy gem does with Trilogy.
  def test_ignores_top_level_class_named_like_the_adapter
    Object.const_set(:OracleEnhanced, Class.new)
    adapter = finder_adapter_for('OracleEnhanced')
    assert_instance_of Geokit::Adapters::OracleEnhanced, adapter
  ensure
    Object.send(:remove_const, :OracleEnhanced)
  end

  def test_unsupported_adapter
    assert_raises(Geokit::ActsAsMappable::UnsupportedAdapter) { finder_adapter_for('Unknown') }
  end

  private

  # Resolves the adapter on a throwaway model whose connection reports the given
  # adapter name, leaving Location's real connection and memoized adapter untouched.
  def finder_adapter_for(adapter_name)
    fake_connection = Struct.new(:adapter_name).new(adapter_name)
    model = Class.new(Location) { define_singleton_method(:connection) { fake_connection } }
    model.geokit_finder_adapter
  end
end
