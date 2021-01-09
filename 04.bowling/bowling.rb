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

  frame << 0 if frame[0] == 10

  if frame.size == 2 || scores[i + 1].nil?
    frames << frame
    frame = []
  end
end

# 得点を足していく
total_score = 0
frames.each_with_index do |f, i|
  total_score +=
    # strikeの場合
    if f[0] == 10 && i < 9
      # 次のフレームもstrikeの場合
      if frames[i + 1][0] == 10
        10 + 10 + frames[i + 2][0]
      else
        10 + frames[i + 1].sum
      end
    # spareの場合
    elsif f.sum == 10 && i < 9
      10 + frames[i + 1][0]
    # それ以外
    else
      f.sum
    end
end

p total_score
