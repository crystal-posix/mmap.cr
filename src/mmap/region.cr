class Mmap::Region
  include Mmap

  def self.open(*args)
    mmap = new *args
    begin
      yield mmap
    ensure
      mmap.close
    end
  end

  @pointer : UInt8*
  @size : LibC::SizeT
  getter? closed = false

  def initialize(size, flags = nil, *, prot : Prot = Prot::ReadWrite, shared : Bool = false, file : File? = nil, offset = 0, addr : Pointer(Void)? = nil)
    @size = size = LibC::SizeT.new(size)
    flags2 = (shared ? LibC::MAP_SHARED : LibC::MAP_PRIVATE)
    flags2 |= LibC::MAP_ANON if file.nil?
    flags2 |= flags.to_i if flags
    fd = file.try(&.fd) || -1

    ptr = LibC.mmap(addr, @size, prot, flags2, fd, offset)
    raise RuntimeError.from_errno("mmap size=#{size} prot=#{prot} flags=#{flags2} fd=#{fd} offset=#{offset}") if ptr == LibC::MAP_FAILED

    @pointer = ptr.as(Pointer(UInt8))
  end

  # *size* limited to Int32 for due to `Slice` limitations
  def [](idx, size) : SubRegion
    range_check idx, size
    SubRegion.new self, idx.to_i64, size.to_i32
  end

  def resize(size, moveable : Bool = false) : Nil
    check_closed

    size = LibC::SizeT.new size
    flags = moveable ? LibC::MREMAP_MAYMOVE : 0

    ptr = LibC.mremap(@pointer, @size, size, flags)
    raise RuntimeError.from_errno("mremap") if ptr == LibC::MAP_FAILED

    @pointer = ptr.as(Pointer(UInt8))
    @size = size
  end

  def close : Nil
    return if closed?
    @closed = true

    r = LibC.munmap @pointer, @size
    raise RuntimeError.from_errno("munmap") if r != 0
  end

  def to_slice : Bytes
    check_closed
    Slice.new @pointer, @size
  end

  # :nodoc:
  def finalize
    close
  end

  protected def check_closed : Nil
    raise Error::Closed.new if @closed
  end

  protected def range_check(idx, size = 0) : Nil
    check_closed
    raise IndexError.new("idx + size out of bounds") if idx + size > @size
  end

  protected def range_checked_pointer(idx, size = 0) : Pointer(UInt8)
    range_check idx, size
    to_unsafe + idx
  end

  # :nodoc:
  def to_unsafe
    check_closed
    @pointer
  end
end
