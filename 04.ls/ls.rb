#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3
MIN_COLUMN_WIDTH = 16
COLUMN_PADDING = 8

def main
  filenames = fetch_visible_filenames
  max_filename_length = find_max_filename_length(filenames)
  column_width = determine_column_width(max_filename_length)
  padded_filenames = pad_filenames(filenames, column_width)
  rows = arrange_into_rows(padded_filenames)
  display_filenames(rows)
end

def fetch_visible_filenames
  Dir.entries('.').reject { |entry| entry.start_with?('.') }.sort
end

def find_max_filename_length(filenames)
  filenames.map(&:length).max
end

def determine_column_width(max_filename_length)
  column_width = [(max_filename_length.to_f / COLUMN_PADDING).ceil * COLUMN_PADDING, MIN_COLUMN_WIDTH].max
  column_width += COLUMN_PADDING if column_width == max_filename_length
  column_width
end

def pad_filenames(filenames, column_width)
  filenames.map { |filename| filename.ljust(column_width) }
end

def arrange_into_rows(padded_filenames)
  row_count = (padded_filenames.size.to_f / COLUMN_COUNT).ceil
  rows = Array.new(row_count) { [] }

  padded_filenames.each_with_index do |filename, index|
    rows[index % row_count] << filename
  end

  rows
end

def display_filenames(rows)
  rows.each { |row| puts row.join }
end

main if $PROGRAM_NAME == __FILE__
