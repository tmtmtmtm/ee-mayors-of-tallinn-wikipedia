#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/date_dotted'
require_relative 'lib/date_partial'
require_relative 'lib/remove_notes'
require_relative 'lib/scraped_wikipedia_officeholders'
require_relative 'lib/unspan_all_tables'
require_relative 'lib/wikipedia_officeholder_page'
require_relative 'lib/wikipedia_officeholder_row'

# The Wikipedia page with a list of officeholders
class ListPage < WikipediaOfficeholderPage
  decorator RemoveNotes
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  def wanted_tables
    tables_with_header('office').first
  end
end

# Each officeholder in the list
class HolderItem < WikipediaOfficeholderRow
  def columns
    %w[ordinal dates name _party _notes]
  end

  def start_date_str
    # handle formats like "March - Sepember 2013"
    unless dates.first.chars.last[/[0-9]/]
      return [dates.first, end_date.split('-').first].join(' ')
    end

    dates.first
  end

  def end_date_str
    return if dates.last.include? 'present'

    dates.last
  end

  def dates
    cell_for('dates').text.tidy.split(/\s*–\s*/)
  end

  def dateclass
    Date::Partial
  end

  def empty?
    cell_for('ordinal').text.tidy.to_i < 32
  end
end

url = ARGV.first || abort("Usage: #{$0} <url to scrape>")
puts Scraped::Wikipedia::OfficeHolders.new(url => ListPage).to_csv
