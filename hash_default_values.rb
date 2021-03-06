# Usually we define Hash:
hash = {}
# and verify the value whether or not exist
if hash[:key]
end

# but if we define default value of Hash
hash = Hash.new(0)
# hash[:key] will always return value not nil

# ----
# sometimes we can see the following code:
hash = Hash.new { |hash, key| hash[key] = [] }
hash[:weekdays] << "Monday"
hash[:holidays]  #=> []
hash.keys  #=> [:weekdays, :holidays]
# this means: when we accessing the key whether or not exist, once accessed,
#             a default value is assigned.

# ---
# we can use Hash#fetch
hash = {}
hash.fetch(:key, []) #=> return [] not nil


# ---
# and use reduce, should use Hash#update to update the initial value
%w[1 2 3].reduce({}){ |hash, key| hash.update({ key => key.to_i }) } # => {"1"=>1, "2"=>2, "3"=>3}
