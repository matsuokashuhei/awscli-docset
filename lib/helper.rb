# frozen_string_literal: true

require 'down'
require 'open-uri'
require_relative 'aws'
require_relative 'docset'

def extract_body_content_from_document(url)
  body = Nokogiri::HTML(open(url))
  [
    'div.navbar.navbar-fixed-top',
    'div.top-links',
    'div.related',
    'div.sphinxsidebar',
    'div.body > p',
    'div.footer-links',
    'div.footer.container'
  ].each do |selector|
    body.css(selector).each(&:remove)
  end
  body
end

def download_stylesheets
  Nokogiri::HTML(open(AWS::ROOT_URL)).css('link').select do |link|
    link.attribute('rel').value == 'stylesheet'
  end.map do |link|
    File.join(File.dirname(AWS::ROOT_URL), link.attribute('href').value)
  end.each do |stylesheet|
    docset_url = Docset.convert_to_docset_url(stylesheet)
    FileUtils.mkdir_p(File.dirname(docset_url))
    Down.download(stylesheet, destination: docset_url)
  end
end
