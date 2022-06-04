# mmap
[![Crystal CI](https://github.com/crystal-posix/mmap.cr/actions/workflows/crystal.yml/badge.svg)](https://github.com/crystal-posix/mmap.cr/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/crystal-posix/mmap.cr.svg)](https://github.com/crystal-posix/mmap.cr/releases)
![GitHub commits since latest release (by date) for a branch](https://img.shields.io/github/commits-since/crystal-posix/mmap.cr/latest)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://crystal-posix.github.io/mmap.cr/main)

mmap() bindings for Crystal

## Design
Platform specific flags are ignored when unsupported and it is safe to do so.

## Supports:
- [x] mremap
- [x] mprotect
- [x] madvise
- [x] mlock
- [x] msync

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mmap:
       github: crystal-posix/mmap.cr
   ```

2. Run `shards install`

## Usage

### Map anonymous memory
```crystal
require "mmap"

Mmap::Region.open(16384) do |mmap|
  # Do something with slice
  mmap.to_slice


  # SubRegions reference the original Mmap::Region, tracking the offset if resized
  rw_region = mmap[0, 4096]
  # Do something with the first 4k
  rw_region.to_slice


  key_region = mmap[4096, 4096]
  # Keep region from being swapped
  key_region.mlock


  # Create a guard page
  guard_region = mmap[12288, 4096]
  guard_region.guard_page
  # Crashes program if accessed
  guard_region.to_slice[0] = 0_u8
end
```

### Map a file for read
```crystal
File.open("a_file.txt") do |file|
  Mmap::Region.new(file.info.size, file: file, prot: Mmap::Prot::Read) do |mmap|
    # May be faster than file.read if the file is cached
    # May be slower than file.read if the file isn't cached especially without -Dpreview_mt
    http.response.send mmap.to_slice
  end
end
```

### Map a file for write
```crystal
File.open("a_file.txt", "w") do |file|
  Mmap::Region.open(file.info.size, shared: true, file: file) do |mmap|
    # Do something with slice
    mmap.to_slice
  end
end
```

## Benchmarks
```
IO#read_fully vs mmap for several file sizes

   read 8192 235.83k (  4.24µs) (± 6.34%)  656B/op        fastest
   mmap 8192 189.03k (  5.29µs) (± 5.52%)  768B/op   1.25× slower
  read 65536 137.22k (  7.29µs) (± 4.29%)  656B/op   1.72× slower
  mmap 65536 188.94k (  5.29µs) (± 6.14%)  768B/op   1.25× slower
read 1048576   9.09k (110.00µs) (± 3.95%)  656B/op  25.94× slower
mmap 1048576 179.55k (  5.57µs) (± 5.32%)  768B/op   1.31× slower

```

## Contributing

1. Fork it (<https://github.com/your-github-user/mmap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Didactic Drunk](https://github.com/didactic-drunk) - creator and maintainer
