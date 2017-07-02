require 'benchmark'
require 'set'

@arr = ('a'..'z').to_a
@hash = Hash[@arr.map { |a| [a, true] }]
# hash = arr.reduce({}) { |hash, ele| hash.update(ele => true) }
@set = Set.new(@arr)

def bm_array
  @arr.include?('t')
end

def bm_hash
  @hash.include?('t')
end

def bm_set
  @set.include?('t')
end

n = 1_000_000
Benchmark.bmbm do |x|
  x.report("Array#include?") do
    n.times { bm_array }
  end
  x.report("Hash#include?") do
    n.times { bm_hash }
  end
  x.report("Set#include?") do
    n.times { bm_set }
  end
end

# Rehearsal --------------------------------------------------
# Array#include?   0.530000   0.000000   0.530000 (  0.542145)
# Hash#include?    0.180000   0.000000   0.180000 (  0.194843)
# Set#include?     0.190000   0.010000   0.200000 (  0.198033)
# ----------------------------------------- total: 0.910000sec

#                      user     system      total        real
# Array#include?   0.540000   0.000000   0.540000 (  0.559832)
# Hash#include?    0.190000   0.000000   0.190000 (  0.192784)
# Set#include?     0.180000   0.010000   0.190000 (  0.190937)
