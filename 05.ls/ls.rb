#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# パーミッションを数字からrwx形式に変換するメソッド
def generate_permission_text(file_stat)
  modes = {
    '1': '--x',
    '2': '-w-',
    '3': '-wx',
    '4': 'r--',
    '5': 'r-x',
    '6': 'rw-',
    '7': 'rwx'
  }
  mode = format('%o', file_stat.mode)
  chars_mode = mode.slice(-3, 3).chars
  text = ''
  chars_mode.each do |t|
    text += modes[t.to_sym]
  end
  text
end

# -lオプションを指定した場合の出力文字列生成メソッド
def generate_output_string_for_l_option(output_files, path)
  # ファイルタイプの定義
  types = {
    directory: 'd',
    file: '-'
  }
  # 出力処理
  output_files.each do |file|
    # ファイル情報を取得
    fs = File.stat("#{path}#{file}")

    # 出力文字列を生成
    text = types[fs.ftype.to_sym] # ファイルタイプ
    text += generate_permission_text(fs) # パーミッション
    text += " #{fs.nlink.to_s.rjust(2)}" # ハードリンク
    text += " #{Etc.getpwuid(fs.uid).name}" # ユーザー名
    text += "  #{Etc.getgrgid(fs.gid).name}" # グループ名
    text += " #{fs.size.to_s.rjust(5)}" # ファイルサイズ
    text += " #{fs.mtime.strftime('%b %e %H:%M')}" # タイムスタンプ
    text += " #{file}" # ファイル名
    puts text
  end
end

# -lオプションを指定しない場合の出力文字列生成メソッド
def generate_output_string(column, row, output_files)
  row.times do |row_repeat_num|
    output_text = []
    target_index = row_repeat_num

    column.times do |column_repeat_num|
      target_index += row if column_repeat_num.positive? # 初回のループ時はインデックスを更新しない
      output_text << output_files[target_index] if output_files[target_index]
    end

    output_text.each { |f| print f.ljust(24) }
    print "\n"
  end
end

options = ARGV.getopts('arl')
target = ARGV[0] if ARGV[0]

# 引数で指定されたものがファイルなのかディレクトリなのか判定
if target
  begin
    case File.stat(target).ftype
    when 'directory'
      files = Dir.entries(target)
      path = target
    when 'file'
      files = [target]
      path = ''
    end
  # 指定ファイルが存在しない場合は例外発生
  rescue Errno::ENOENT
    puts "ls: #{ARGV[0]}: No such file or directory"
    exit
  end
# ファイルやディレクトリが指定されていない場合、カレントディレクトリを対象
else
  files = Dir.entries('.')
  path = './'
end

# 並びのソート(-rオプションがあれば逆順に)
output_files = options['r'] ? files.sort.reverse : files.sort

# .で始まるファイル名を配列から取り除く(-aオプションがない場合)
output_files = output_files.reject { |file| file =~ /^\..?/ } unless options['a']

files_size = output_files.size # ファイル数

# 出力処理
# -lオプションが指定されている場合
if options['l']
  require 'etc'

  puts "total #{files_size}"
  generate_output_string_for_l_option(output_files, path)
# -lオプションなし
else
  column = 3 # 列数
  row = (files_size / column.to_f).ceil # 行数

  generate_output_string(column, row, output_files)
end
