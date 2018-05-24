# Sometimes you will look this
# http://benjamintan.io/blog/2015/03/28/ruby-block-patterns-and-how-to-implement-file-open/
file = File.open(file_name, 'w') do
  # do something
  # if raise exception?
  # the file can close itself? Yes!
end

# and if you do like that
f = File.open('Leo Tolstoy - War and Peace.txt', 'w')
f << "Well, Prince, so Genoa and Lucca"
f << " are now just family estates of the Buonapartes."
f.close

# when write file raise exception, file can't be closed correct.
begin
  f = File.open('Leo Tolstoy - War and Peace.txt', 'w')
  f << "Well, Prince, so Genoa and Lucca"
  f << " are now just family estates of the Buonapartes."
ensure
  f&.close
end
