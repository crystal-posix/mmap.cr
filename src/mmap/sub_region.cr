struct Mmap::SubRegion
  include Mmap

  # :nodoc:
  def initialize(@mmap : Region, @idx : Int32, @size : Int32)
  end

  # Returns a new SubRegion referencing the original Region
  def [](idx, size) : self
    SubRegion.new @mmap, (@idx + idx), size
  end

  def to_unsafe
    @mmap.range_checked_pointer @idx
  end


  protected def range_checked_pointer(idx, size = 0) : Pointer(UInt8)
    @mmap.range_checked_pointer(@idx + idx, size)
  end
end
