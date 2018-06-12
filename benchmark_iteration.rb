# https://ruby-china.org/topics/36789
require 'benchmark'

ARRAY = [1, 2, 3, 4].freeze

def each_with_object_and_compact_and_join
  [1, 2, 3, 4].each_with_object([]) { |i, x| x << [x.last, i].compact.join('/') }
end

def map_with_index_and_join
  ARRAY.map.with_index { |i,index| ARRAY[0, index+1].join('/') }
end

def map_with_join
  (0..ARRAY.size-1).map { |index| ARRAY[0, index+1].join('/') }
end

def map_with_join_from_1
  (1..ARRAY.size).map { |index| ARRAY[0, index].join('/') }
end

def map_with_index_and_first_and_join
  ARRAY.map.with_index(1) { |_, i| ARRAY.first(i).join('/') }
end

def upto_and_map_and_take_and_join
  1.upto(ARRAY.size).map{ |i| ARRAY.take(i).join '/' }
end

def each_and_push_to_new_arr
  str_arr = []
  str = ''
  ARRAY.each {|e| str == '' ? str = "#{e}" : str = "#{str}/#{e}"; str_arr << str }
end

def upto_collect_join
  0.upto(ARRAY.size - 1).collect { |len| ARRAY[0..len].join('/') }
end

def array_new_join
  Array.new(ARRAY.size) { |len| ARRAY[0..len].join('/') }
end

def yield_self_array_new_join
  [1, 2, 3, 4].yield_self { |arr| Array.new(ARRAY.size) { |len| ARRAY[0..len].join('/') } }
end

n = 1_000_000
Benchmark.bmbm do |x|
  x.report("each_with_object_and_compact_and_join") do
    n.times { each_with_object_and_compact_and_join }
  end
  x.report("map_with_index_and_join") do
    n.times { map_with_index_and_join }
  end
  x.report("map_with_join") do
    n.times { map_with_join }
  end
  x.report("map_with_join_from_1") do
    n.times { map_with_join_from_1 }
  end
  x.report("map_with_index_and_first_and_join") do
    n.times { map_with_index_and_first_and_join }
  end
  x.report("upto_and_map_and_take_and_join") do
    n.times { upto_and_map_and_take_and_join }
  end
  x.report("each_and_push_to_new_arr") do
    n.times { each_and_push_to_new_arr }
  end
  x.report("upto_collect_join") do
    n.times { upto_collect_join }
  end
  x.report("array_new_join") do
    n.times { array_new_join }
  end
  x.report("yield_self_array_new_join") do
    n.times { yield_self_array_new_join }
  end
end

# ruby version: 2.5.1
# Rehearsal -------------------------------------------------------------------------
# each_with_object_and_compact_and_join   5.667969   0.059941   5.727910 (  6.664455)
# map_with_index_and_join                 7.146387   0.079972   7.226359 (  7.612205)
# map_with_join                           6.740644   0.070485   6.811129 (  7.157109)
# map_with_join_from_1                    6.760810   0.071053   6.831863 (  7.163527)
# map_with_index_and_first_and_join       6.583269   0.042844   6.626113 (  6.735624)
# upto_and_map_and_take_and_join          6.753501   0.040741   6.794242 (  6.874045)
# each_and_push_to_new_arr                1.907668   0.006618   1.914286 (  1.926558)
# upto_collect_join                       7.020322   0.025586   7.045908 (  7.084592)
# array_new_join                          6.216388   0.020994   6.237382 (  6.270197)
# yield_self_array_new_join               6.649032   0.028160   6.677192 (  6.722629)
# --------------------------------------------------------------- total: 61.892384sec

#                                             user     system      total        real
# each_with_object_and_compact_and_join   5.769904   0.068419   5.838323 (  6.582313)
# map_with_index_and_join                 7.055883   0.063566   7.119449 (  7.623106)
# map_with_join                           6.687854   0.057547   6.745401 (  7.120873)
# map_with_join_from_1                    6.617080   0.054467   6.671547 (  7.045017)
# map_with_index_and_first_and_join       7.242353   0.074787   7.317140 (  8.075503)
# upto_and_map_and_take_and_join          7.217640   0.080263   7.297903 (  7.755439)
# each_and_push_to_new_arr                2.060703   0.018830   2.079533 (  2.180021)
# upto_collect_join                       7.790620   0.071436   7.862056 (  8.370864)
# array_new_join                          6.719938   0.067221   6.787159 (  7.029963)
# yield_self_array_new_join               7.202502   0.081633   7.284135 (  7.515367)