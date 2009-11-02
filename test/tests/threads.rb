## This is a simple (unscientific) test to try and simulate the behaviour when two workers
## are polling at the same time.

$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'runa'

Runa.backend.delete('hashlist')
Runa.backend.push_tail 'hashlist', "A"
Runa.backend.push_tail 'hashlist', "B"

Process.fork
puts Time.now.to_f
puts Runa.backend.pop_head('hashlist')
