# frozen_string_literal: true

require "optparse"
require "bundler/setup"
Bundler.require

loader = Zeitwerk::Loader.for_gem
loader.setup
