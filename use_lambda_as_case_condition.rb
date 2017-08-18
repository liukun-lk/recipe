even = ->(x) { (x % 2) == 0 }

even === 4  #=> true
even === 9  #=> false

# so you can use
case number
when 42
  puts 'the ultimate answer'
when even
  puts 'even'
else
  puts 'odd'
end
