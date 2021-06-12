# mmap

mmap() bindings for Crystal

## Todo:
- [ ] mremap
- [x] mprotect
- [ ] madvise
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


  # Not a Slice
  rw_region = mmap[0, 4096]
  # Do something with the first 4k
  rw_region.to_slice


  key_region = mmap[4096, 4096]
  # Keep region from being swapped
  key_region.mlock


  # Create a guard page
  guard_region = mmap[12288, 4096]
  guard_region.mprotect Mmap::Prot::None
  # Crashes program if accessed
  guard_region.to_slice[0] = 0_u8
end
```

### Map a file for read
```crystal
File.open("a_file.txt", "r") do |file|
  mmap = Mmap::Region.new(file.info.size, file: file, prot: Mmap::Prot::Read)
  # May be faster than file.read if the file is cached
  # May be slower than file.read if the file isn't cached especially without -Dpreview_mt
  http.response.send mmap.to_slice
  mmap.close
end
```

### Map a file for write
```crystal
File.open("a_file.txt", "r") do |file|
  mmap = Mmap::Region.new(file.info.size, shared: true, file: file)
  # Do something with slice
  mmap.to_slice
  mmap.close
end
```


## Contributing

1. Fork it (<https://github.com/your-github-user/mmap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Didactic Drunk](https://github.com/didactic-drunk) - creator and maintainer
