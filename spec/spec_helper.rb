APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$: << File.join(APP_ROOT, 'lib')

RSpec.configure do |config|
  config.order = 'random'
end
