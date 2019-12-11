# frozen_string_literal: true

require 'sqlite3'

class DB
  def self.create(operation)
    connection.execute('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?)', values(operation))
  end

  def self.find(operation)
    connection.execute('SELECT * FROM searchIndex WHERE name = ? AND type = ? AND path = ?', values(operation))
  end

  def self.values(operation)
    name, type = if operation.is_a?(AWS)
                   [operation.name, 'Provider']
                 elsif operation.is_a?(Service)
                   [operation.name, 'Service']
                 elsif operation.is_a?(Command)
                   [operation.full_name, 'Command']
                 else
                   raise ArgumentError, 'opertion is unknown.'
                 end
    path = operation.url.gsub('https://docs.aws.amazon.com/cli/latest/', '')
    [name, type, path]
  end

  def self.connection
    @@conn ||= SQLite3::Database.new('awscli.docset/Contents/Resources/docSet.dsidx')
  end

  def self.clean
    puts 'clear DB in awscli.docset/Contents/Resources/docSet.dsidx'
    connection.execute('DELETE FROM searchIndex')
  end
end
