#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  filenames = fetch_visible_filenames

  columns = split_into_column(filenames)
  formated_columns = format_columns(columns)

  rows = arrange_into_rows(formated_columns)
  display_filenames(rows)
end

def fetch_visible_filenames
  Dir.entries('./test').reject { |entry| entry.start_with?('.') }.sort
end

def format_columns(columns)
  columns.map do |column|
    max_filename_length = find_max_filename_length(column)
    column_width = determine_column_width(max_filename_length)
    padded_column = pad_filenames(column, column_width)
  end
end

def split_into_column(filenames)
  row_count = (filenames.size / COLUMN_COUNT).ceil
  filenames.each_slice(row_count).to_a
end

def find_max_filename_length(filenames)
  filenames.map(&:length).max
end

def determine_column_width(max_filename_length)
  max_filename_length + 2
end

def pad_filenames(column, column_width)
  column.map { |cell| cell.ljust(column_width) }
end

def arrange_into_rows(formated_columns)
  filenames = formated_columns.flatten

  row_count = (filenames.size.to_f / COLUMN_COUNT).ceil
  rows = Array.new(row_count) { [] }

  filenames.each_with_index do |filename, index|
    rows[index % row_count] << filename
  end

  rows
end

def display_filenames(rows)
  rows.each { |row| puts row.join }
end

main if $PROGRAM_NAME == __FILE__
