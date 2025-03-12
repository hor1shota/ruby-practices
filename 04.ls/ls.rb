#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3
COLUMN_PADDING = 2
TARGET_DIR = '.'

def main
  params = parse_params
  file_names = fetch_visible_file_names
  return if file_names.empty?

  if params[:l]
    file_stats = file_names.map { |file_name| fetch_file_info(file_name) }
    max_field_widths = calculate_max_field_widths(file_stats)
    print_files_detailed(file_stats, max_field_widths)
  else
    columns = divide_into_columns(file_names)
    formatted_columns = format_columns(columns)
    rows = transpose_columns_to_rows(formatted_columns)
    print_files(rows)
  end
end

def parse_params
  option_parser = OptionParser.new
  params = {}
  option_parser.on('-l', 'List files in the long format.')
  option_parser.parse(ARGV, into: params)

  params
end

def fetch_visible_file_names
  Dir.entries(TARGET_DIR).reject { |entry| entry.start_with?('.') }.sort_by(&:downcase)
end

def fetch_file_info(file_name)
  file_path = File.join(TARGET_DIR, file_name)
  file_stat = File.symlink?(file_path) ? File.lstat(file_path) : File.stat(file_path)

  mode_str = file_stat.mode.to_s(8).rjust(6, '0')
  match = mode_str.match(/^(\d{2}).(\d{3})$/)

  {
    file_type: convert_file_type_format(match[1]),
    permissions: match[2].each_char.map { |permission| convert_permission_format(permission) }.join,
    hard_link_count: file_stat.nlink,
    owner: Etc.getpwuid(file_stat.uid).name,
    group: Etc.getgrgid(file_stat.gid).name,
    file_size: file_stat.size,
    update_time: file_stat.mtime.strftime('%_2m %_2d %H:%M'),
    file_name: File.symlink?(file_name) ? convert_link_format(file_name) : file_name
  }
end

def calculate_max_field_widths(file_stats)
  {
    hard_link: file_stats.map { |file_stat| file_stat[:hard_link_count].to_s.length }.max,
    owner: file_stats.map { |file_stat| file_stat[:owner].length }.max,
    group: file_stats.map { |file_stat| file_stat[:group].length }.max,
    file_size: file_stats.map { |file_stat| file_stat[:file_size].to_s.length }.max
  }
end

def print_files_detailed(file_stats, max_field_widths)
  file_stats.each do |file_info|
    format = "%s%s  %#{max_field_widths[:hard_link]}d %-#{max_field_widths[:owner]}s  %-#{max_field_widths[:group]}s  %#{max_field_widths[:file_size]}d %s %s"

    puts format(format, *file_info.values)
  end
end

def convert_file_type_format(file_type)
  {
    '04' => 'd',
    '10' => '-',
    '12' => 'l'
  }[file_type]
end

def convert_permission_format(permission)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[permission]
end

def convert_link_format(symlink_path)
  target_path = File.readlink(symlink_path)
  "#{symlink_path} -> #{target_path}"
end

def format_columns(columns)
  columns.map do |column|
    max_length = max_file_name_length(column)
    column_width = calculate_column_width(max_length)
    pad_file_names(column, column_width)
  end
end

def divide_into_columns(file_names)
  row_count = (file_names.size / COLUMN_COUNT).ceil
  file_names.each_slice(row_count).to_a
end

def max_file_name_length(file_names)
  file_names.map(&:length).max
end

def calculate_column_width(max_file_name_length)
  max_file_name_length + COLUMN_PADDING
end

def pad_file_names(column, column_width)
  column.map { |cell| cell.ljust(column_width) }
end

def transpose_columns_to_rows(formatted_columns)
  file_names = formatted_columns.flatten

  row_count = (file_names.size / COLUMN_COUNT).ceil
  rows = Array.new(row_count) { [] }

  file_names.each_with_index do |file_name, index|
    rows[index % row_count] << file_name
  end

  rows
end

def print_files(rows)
  puts rows.map(&:join)
end

main if $PROGRAM_NAME == __FILE__
