# Sometimes you will look this
begin
  file = File.open(file_name, 'w') do
    # do something
    # if raise exception?
    # the file can close itself?
  end
ensure
  file.close if file
end
