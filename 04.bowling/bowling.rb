#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0] # スコアの受け取り

scores = score.chars # 1文字ずつ分割して、配列に

frame = [] # 1フレーム分の得点を格納する配列
frames = [] # 全フレームを格納する配列

# 1つずつ数字に変換しながらframeに格納。ストライクの場合は2投目に0
# frameの数字が2つになるか、最後のスコアになったらframesに入れる
scores.each_with_index do |s, i|
  frame << (s == 'X' ? 10 : s.to_i)

  # 9フレーム目までの処理
  if frames.size < 9
    frame << 0 if frame[0] == 10

    if frame.size == 2
      frames << frame
      frame = []
    end
  # 10フレーム目で最後の1文字になったら、framesに格納する
  elsif scores[i + 1].nil?
    frames << frame
  end
end
puts "frames: #{frames}"

# 得点を足していく
total_score = 0
frames.each_with_index do |f, i|
  next_frame = frames[i + 1]
  total_score +=
    # strikeの場合
    if f[0] == 10 && i < 9
      # 次のフレームがストライクか、または9フレーム目かによって加算点を判定
      addition_point = next_frame[0] != 10 || i == 8 ? next_frame[1] : frames[i + 2][0]
      10 + next_frame[0] + addition_point
    # spareの場合
    elsif f.sum == 10 && i < 9
      10 + next_frame[0]
    # それ以外
    else
      f.sum
    end
end

p total_score
