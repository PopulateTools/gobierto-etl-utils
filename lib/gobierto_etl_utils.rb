# frozen_string_literal: true

require "optparse"
require "csv"
require "fileutils"
require "tempfile"
require "bundler/setup"
Bundler.require

loader = Zeitwerk::Loader.for_gem
loader.setup
