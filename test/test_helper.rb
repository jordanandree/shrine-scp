require "bundler/setup"
require "pry-byebug"

require "minitest/autorun"
require "minitest/pride"

require "shrine"
require "shrine/storage/rsync"

require_relative "support/fakeio"
