# frozen_string_literal: true

require 'fileutils'
require_relative 'aws'

module Docset
  ROOT_URL = 'awscli.docset/Contents/Resources/Documents'

  def self.store(operation)
    path = convert_to_docset_url(operation.url)
    return if File.exist?(path)

    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |file|
      file.write(operation.document.to_html)
    end
  end

  def self.convert_to_docset_url(url)
    File.join(ROOT_URL, url.gsub('https://docs.aws.amazon.com/cli/latest/', ''))
  end

  def self.clean
    Dir.new(ROOT_URL).children.filter do |dir|
      dir != '.keep'
    end.map do |dir|
      File.join(ROOT_URL, dir)
    end.each do |dir|
      FileUtils.rm_rf(dir)
    end
  end
end
