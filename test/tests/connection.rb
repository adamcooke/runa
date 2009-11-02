require File.join(File.dirname(__FILE__), '..', 'helper') 
 
class TestConnection < Test::Unit::TestCase
  
  def test_connection
    assert Runa.backend.is_a?(Redis)
    assert_equal "127.0.0.1:6379", Runa.backend.server
  end
  
  def test_values_can_be_stored_in_backend
    Runa.backend['foo'] = 'bar'
    assert_equal 'bar', Runa.backend['foo']
    assert_equal nil, Runa.backend['foobar']
    assert Runa.backend.delete('foo')
  end
  
  def test_storing_lists
    Runa.delete('testlist')
    Runa.push 'testlist', "abc"
    Runa.push 'testlist', 'def'
    assert ['abc', 'def'], Runa.backend.list_range('testlist', 0, 5)
    Runa.delete('testlist')
  end
  
  def test_storing_hashes_in_lists
    hash = {:a => "b", :c => "d"}
    hash2 = {:e => "f", :g => "h"}
    Runa.delete('hashlist')
    Runa.push 'hashlist', hash
    Runa.push 'hashlist', hash2
    
    assert hash, Runa.pull('hashlist')
    assert hash, Runa.pull('hashlist')
    assert [], Runa.backend.list_range('hashlist', 0, 5)
  end
    
end