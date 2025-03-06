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

  return print_long_format(file_names) if params[:l]

  columns = divide_into_columns(file_names)
  formatted_columns = format_columns(columns)

  rows = transpose_columns_to_rows(formatted_columns)
  print_file_names(rows)
end

def parse_params
  option_parser = OptionParser.new
  params = {}
  option_parser.on('-l', 'List files in the long format.')
  option_parser.parse(ARGV, into: params)

  params
end

def fetch_visible_file_names
  entries = Dir.entries(TARGET_DIR).reject { |entry| entry.start_with?('.') }.sort_by(&:downcase)
end

def print_long_format(file_names)
  max_hard_link_width = file_names.map { |file_name| File.stat(file_name).nlink.to_s.length  }.max
  max_file_size_width = file_names.map { |file_name| File.stat(file_name).size.to_s.length  }.max
  max_owner_width = file_names.map { |file_name| Etc.getpwuid(File.stat(file_name).uid).name.length }.max
  max_group_width = file_names.map { |file_name| Etc.getgrgid(File.stat(file_name).gid).name.length }.max

  file_names.each do |file_name|
    file_stat = File.symlink?(file_name) ? File.lstat(file_name) : File.stat(file_name)

    mode_str = file_stat.mode.to_s(8).rjust(6, '0')
    match = mode_str.match(/^(\d{2}).(\d{3})$/)

    file_type = convert_file_type_format(match[1])
    permissions = match[2].each_char.map { |permission| convert_permission_format(permission) }.join

    hard_link_count = file_stat.nlink
    owner = Etc.getpwuid(file_stat.uid).name
    group = Etc.getgrgid(file_stat.gid).name
    file_size = file_stat.size

    time_format = '%_2m %_2d %H:%M'
    update_time = file_stat.mtime.strftime(time_format)

    file_name = convert_link_format(file_name) if File.symlink?(file_name)

    printf "%s%s  %#{max_hard_link_width}d %#{max_owner_width}s  %#{max_group_width}s  %#{max_file_size_width}d %s %s\n",
            file_type, permissions, hard_link_count, owner, group, file_size, update_time, file_name
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
  }[permission] || '?'
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

def print_file_names(rows)
  puts rows.map(&:join)
end

main if $PROGRAM_NAME == __FILE__
