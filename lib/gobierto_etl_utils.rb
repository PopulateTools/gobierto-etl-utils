# frozen_string_literal: true

# Set up the bundle first, or `require "csv"` activates the global gem instead of the locked one
require "bundler/setup"
Bundler.require
require "optparse"
require "csv"
require "fileutils"
require "cgi"
require "tempfile"

loader = Zeitwerk::Loader.for_gem
loader.setup
