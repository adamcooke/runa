$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test/unit'
require 'runa'

Runa.key_prefix = "test"
