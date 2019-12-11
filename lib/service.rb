# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require_relative 'helper'
require_relative 'aws'
require_relative 'command'
require_relative 'docset'

class Service

  ROOT_URL = 'https://docs.aws.amazon.com/cli/latest/index.html'
  attr_reader :name

  def initialize(name:)
    @name = name
  end

  def url
    File.join(File.dirname(AWS.url), name, 'index.html')
  end

  def document
    @doc ||= extract_body_content_from_document(url)
  end

  def commands
    anchors = document.css('div.toctree-wrapper.compound > ul > li > a')
    anchors.map do |anchor|
      Command.new(service: self, name: anchor.text)
    end
  end
end
