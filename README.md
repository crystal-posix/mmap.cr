# mmap

mmap() bindings for Crystal

## Todo:
- [ ] mremap
- [ ] mprotect
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

Mmap.open(4096) do |mmap|
  mmap.to_slice # Do something with slice
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
