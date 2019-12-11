# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require_relative 'helper'

class Command
  attr_reader :service, :name

  def initialize(service:, name:)
    @service = service
    @name = name
  end

  def url
    File.join(File.dirname(service.url), "#{name}.html")
  end

  def document
    @doc ||= extract_body_content_from_document(url)
  end

  def full_name
    "#{service.name} #{name}"
  end
end
