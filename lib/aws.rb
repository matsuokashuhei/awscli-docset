# frozen_string_literal: true

require_relative 'helper'
require_relative 'service'

class AWS
  ROOT_URL = 'https://docs.aws.amazon.com/cli/latest/index.html'

  def self.url
    'https://docs.aws.amazon.com/cli/latest/reference/index.html'
  end

  def self.document
    @@doc ||= extract_body_content_from_document(url)
  end

  def self.services
    anchors = document.css('div.toctree-wrapper.compound > ul > li > a')
    anchors.map do |anchor|
      Service.new(name: anchor.text)
    end
  end
end
