# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'sqlite3'

CLI_ROOT_URL = 'https://docs.aws.amazon.com/cli/latest/'

def services(index_url)
  doc = Nokogiri::HTML(open(index_url))
  anchors = doc.css('div.toctree-wrapper.compound > ul > li > ul > li > a')
  anchors.map do |anchor|
    {
      name: anchor.text,
      url: File.join(index_url, anchor.attribute('href'))
    }
  end
end

def commands(service)
  doc = Nokogiri::HTML(open(service[:url]))
  anchors = doc.css('div.toctree-wrapper.compound > ul > li > a')
  anchors.map do |anchor|
    {
      name: anchor.text,
      url: File.join(service[:url].sub('index.html', ''), anchor.attribute('href'))
    }
  end
end

DOCSET_ROOT_URL = 'awscli.docset/Contents/Resources/Documents'

def extract_content(service, command)
  doc = Nokogiri::HTML(open(command[:url]))
  builder = Nokogiri::HTML::Builder.new do |b|
    b.html do
      # b.head do
      #   b << doc.css('head')
      # end
      b.body do
        b << doc.css("##{command[:name]}")
        b << "<a name=\"//apple_ref/cpp/Command/#{service[:name]} #{command[:name]}\" class=\"dashAnchor\"></a>"
      end
    end
  end
  builder.to_html
end

def output_file_path(service, command)
  dir_path = File.join(DOCSET_ROOT_URL, service[:name])
  FileUtils.mkdir_p(dir_path)
  File.join(dir_path, "#{command[:name]}.html")
end

def output(service, command)
  path = output_file_path(service, command)
  File.open(path, 'w') do |file|
    file.write(extract_content(service, command))
  end
end

def reset_db
  db = SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  db.execute('DELETE FROM searchIndex')
end

def populate(service, command)
  name = [service[:name], command[:name]].join(' ')
  type = 'Command'
  path = File.join(service[:name], "#{command[:name]}.html")
  db = SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  db.execute('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?)', [name, type, path])
end

def main
  reset_db
  services(CLI_ROOT_URL).filter do |service|
    %w[
      apigateway
      codebuild
      codepipline
      configure
      dynamodb
      ec2
      ecr
      ecs
      iam
      lambda
      polly
      rds
      s3
      s3api
      sns
      sqs
      sts
    ].include?(service[:name])
  end.each do |service|
    puts service[:name]
    commands(service).each do |command|
      puts command[:name]
      output(service, command)
      populate(service, command)
      sleep(1)
    end
  end
end

main
