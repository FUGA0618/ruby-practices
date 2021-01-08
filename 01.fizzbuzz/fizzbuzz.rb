# frozen_string_literal: true

(1..100).each do |i|
  if (i % 5).zero? && (i % 3).zero?
    puts 'FizzBuzz'
  elsif (i % 3).zero?
    puts 'Fizz'
  elsif (i % 5).zero?
    puts 'Buzz'
  else
    puts i
  end
end
