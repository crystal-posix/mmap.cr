# mmap

mmap() bindings for Crystal

## Todo:
- [ ] mremap
- [x] mprotect
- [ ] madvise
- [ ] mlock
- [ ] msync

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mmap:
       github: crystal-posix/mmap.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "mmap"

Mmap::Region.open(8192) do |mmap|
  # Do something with slice
  mmap.to_slice

  # Not a Slice
  rw_region = mmap[0, 4096]
  # Do something with the first 4k
  rw_region.to_slice

  # Create a guard page
  guard_region = mmap[4096, 4096]
  guard_region.mprotect Mmap::Prot::None
  # Crashes program if accessed
  guard_region.to_slice[0] = 0_u8
end
```

TODO: Write usage instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/mmap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Didactic Drunk](https://github.com/didactic-drunk) - creator and maintainer
