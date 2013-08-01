module Bait
  VERSION = File.open(File.join(File.dirname(__FILE__), "..", "..", "VERSION")){|f| f.read.strip}
end
