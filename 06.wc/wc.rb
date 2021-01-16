#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# 出力するテキストを生成する関数
def generate_output_text(*factors)
  factors.map { |factor| factor.to_s.rjust(8) }.join
end

option = ARGV.getopts('l')

target_files = ARGV[0] ? ARGV : readlines
mode = ARGV[0] ? 'file' : 'stdin'

case mode
# ファイルが指定されている場合の処理
when 'file'
  total_lines = 0
  total_words = 0
  total_bytes = 0

  # 1ファイルごとの処理
  target_files.each_with_index do |file_name, i|
    begin
      lines = File.open(file_name, 'r').readlines.size
      words = File.open(file_name, 'r').read.split(/[　\s]+/).size
      bytes = File.open(file_name, 'r').read.size

      # 1ファイルごとの出力処理
      if option['l']
        puts "#{generate_output_text(lines)} #{file_name}"
      else
        puts "#{generate_output_text(lines, words, bytes)} #{file_name}"
      end

      # 複数ファイルがある場合の処理
      next unless target_files.size > 1

      total_lines += lines
      total_words += words
      total_bytes += bytes

      # total部分の出力処理
      if option['l'] && target_files[i + 1].nil?
        puts "#{generate_output_text(total_lines)} total"
      elsif target_files[i + 1].nil?
        puts "#{generate_output_text(total_lines, total_words, total_bytes)} total"
      end

    # 指定ファイルが存在しない場合はエラーメッセージを表示する
    rescue Errno::ENOENT
      puts "wc: #{file_name}: open: No such file or directory"
    end
  end

# 標準出力が対象の場合の処理
when 'stdin'
  lines = target_files.size

  # 出力処理
  if option['l']
    puts generate_output_text(lines)
  else
    words = target_files.sum('').split(/[　\s]+/).size
    bytes = target_files.sum('').size
    puts generate_output_text(lines, words, bytes)
  end
end
