# frozen_string_literal: true

require 'down'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

CLI_ROOT_URL = 'https://docs.aws.amazon.com/cli/latest/'

def download_css
  doc = Nokogiri::HTML(open(CLI_ROOT_URL))
  doc.css('link').select do |link|
    link.attribute('rel').value == 'stylesheet'
  end.each do |link|
    stylesheet = link.attribute('href').value
    FileUtils.mkdir_p(File.join(DOCSET_ROOT_URL, File.dirname(stylesheet)))
    Down.download(File.join(CLI_ROOT_URL, stylesheet), destination: File.join(DOCSET_ROOT_URL, stylesheet))
  end
end

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

def edit_content(_service, command)
  doc = Nokogiri::HTML(open(command[:url]))
  [
    'div.navbar.navbar-fixed-top',
    'div.top-links',
    'div.related',
    'div.sphinxsidebar',
    'div.body > p',
    'div.footer-links',
    'div.footer.container'
  ].each do |css|
    doc.css(css).each(&:remove)
  end
  doc.to_html
end

def output_file_path(service, command)
  dir_path = File.join(DOCSET_ROOT_URL, 'reference', service[:name])
  FileUtils.mkdir_p(dir_path)
  File.join(dir_path, "#{command[:name]}.html")
end

def output(service, command)
  path = output_file_path(service, command)
  File.open(path, 'w') do |file|
    file.write(edit_content(service, command))
  end
end

def reset_db
  db = SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  db.execute('DELETE FROM searchIndex')
end

def populate(service, command)
  name = [service[:name], command[:name]].join(' ')
  type = 'Command'
  path = File.join('reference', service[:name], "#{command[:name]}.html")
  db = SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  db.execute('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?)', [name, type, path])
end

def find(service, command)
  name = [service[:name], command[:name]].join(' ')
  type = 'Command'
  path = File.join('reference', service[:name], "#{command[:name]}.html")
  db = SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  db.execute('SELECT * FROM searchIndex WHERE name = ? AND type = ? AND path = ?', [name, type, path])
end

def test?
  ARGV[0] == 'test'
end

def main
  # reset_db
  download_css
  services(CLI_ROOT_URL).then do |services|
    if test?
      services.slice(0, 3)
    else
      services
    end
  end.each do |service|
    puts service[:name]
    commands(service).then do |commands|
      if test?
        commands.slice(0, 3)
      else
        commands
      end
    end.each do |command|
      next if find(service, command).first

      puts command[:name]
      output(service, command)
      populate(service, command)
      sleep(1)
    end
  end
end

main
