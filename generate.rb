#!/usr/bin/env ruby
# frozen_string_literal: true

require 'down'
require_relative 'lib/aws'
require_relative 'lib/docset'
require_relative 'lib/db'
require_relative 'lib/helper'

Docset.clean
DB.clean

download_stylesheets

AWS.services.slice(0, 3).each do |service|
  puts service.name
  Docset.store(service)
  DB.create(service)
  service.commands.slice(0, 3).each do |command|
    puts " - #{command.name}"
    Docset.store(command)
    DB.create(command)
  end
end
