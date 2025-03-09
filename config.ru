# frozen_string_literal: true

require './app/main'
require 'zeitwerk'
require 'net/http'
require 'dotenv/load'
require 'faraday'
require 'sequel'

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, 'app'))
loader.setup

Sequel.connect(ENV['DATABASE_URL'])

run Main
