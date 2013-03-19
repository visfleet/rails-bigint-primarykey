require 'benchmark'

n = 50000000
a = [10]*n

Benchmark.bm do |x|
  x.report {
    for i in 1..n
      a.pop
    end
  }
  x.report {
    j = 0
    for i in 1..n
      b = a[j]
      j += 1
    end
  }
end
