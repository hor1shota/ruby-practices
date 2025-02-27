#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_COUNT = 3
COLUMN_PADDING = 2
TARGET_DIR = '.'

def main
  params = parse_params

  filenames = fetch_visible_filenames(params)

  return if filenames.empty?

  columns = divide_into_columns(filenames)
  formatted_columns = format_columns(columns)

  rows = transpose_columns_to_rows(formatted_columns)
  print_filenames(rows)
end

def parse_params
  option_parser = OptionParser.new
  params = {}
  option_parser.on('-a') { |val| params[:a] = val }
  option_parser.parse(ARGV)

  params
end

def fetch_visible_filenames(params)
  Dir.entries(TARGET_DIR)
     .select { |entry| params[:a] || entry.match(/^[^.]/) }
     .sort_by(&:downcase)
end

def format_columns(columns)
  columns.map do |column|
    max_length = max_filename_length(column)
    column_width = calculate_column_width(max_length)
    pad_filenames(column, column_width)
  end
end

def divide_into_columns(filenames)
  row_count = (filenames.size / COLUMN_COUNT).ceil
  filenames.each_slice(row_count).to_a
end

def max_filename_length(filenames)
  filenames.map(&:length).max
end

def calculate_column_width(max_filename_length)
  max_filename_length + COLUMN_PADDING
end

def pad_filenames(column, column_width)
  column.map { |cell| cell.ljust(column_width) }
end

def transpose_columns_to_rows(formatted_columns)
  filenames = formatted_columns.flatten

  row_count = (filenames.size / COLUMN_COUNT).ceil
  rows = Array.new(row_count) { [] }

  filenames.each_with_index do |filename, index|
    rows[index % row_count] << filename
  end

  rows
end

def print_filenames(rows)
  puts rows.map(&:join)
end

main if $PROGRAM_NAME == __FILE__
