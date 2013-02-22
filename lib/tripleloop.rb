basedir = File.realpath(File.dirname(File.dirname(__FILE__)))
$LOAD_PATH << "#{basedir}/lib/tripleloop"
$LOAD_PATH << "#{basedir}/lib/tripleloop/support"

module Tripleloop
end

require 'extractor'
require 'document_processor'
require 'util'