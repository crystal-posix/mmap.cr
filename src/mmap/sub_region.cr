struct Mmap::SubRegion
  include Mmap

  # :nodoc:
  def initialize(@mmap : Region, @idx : Int64, @size : Int32)
  end

  # Returns a new `SubRegion` referencing the original `Region`
  #
  # *size* limited to `Int32` due to `Slice` limitations
  def [](idx, size) : self
    SubRegion.new @mmap, (@idx + idx.to_i64), size.to_i32
  end

  def to_unsafe
    @mmap.range_checked_pointer @idx
  end

  protected def range_checked_pointer(idx, size = 0) : Pointer(UInt8)
    @mmap.range_checked_pointer(@idx + idx, size)
  end
end
