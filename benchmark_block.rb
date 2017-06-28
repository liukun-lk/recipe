require "benchmark"

def speak_with_block(&block)
  block.call
end

def speak_with_yield
  yield
end

def speak_with_proc_new
  Proc.new
end

n = 1_000_000
Benchmark.bmbm do |x|
  x.report("&block") do
    n.times { speak_with_block { "ook" } }
  end
  x.report("yield") do
    n.times { speak_with_yield { "ook" } }
  end
  x.report("proc new") do
    n.times { speak_with_proc_new { "ook" } }
  end
end

# Rehearsal --------------------------------------------
# &block     0.740000   0.010000   0.750000 (  0.762365)
# yield      0.130000   0.000000   0.130000 (  0.139517)
# proc new   0.640000   0.010000   0.650000 (  0.649468)
# ----------------------------------- total: 1.530000sec
#
#                user     system      total        real
# &block     0.730000   0.000000   0.730000 (  0.738845)
# yield      0.130000   0.010000   0.140000 (  0.134963)
# proc new   0.650000   0.000000   0.650000 (  0.666199)
