class Mmap::Region
  include Mmap

  def self.open(size, flags = nil, *, prot : Prot = Prot::ReadWrite, shared : Bool = false, file : File? = nil, offset = 0, addr : Pointer(Void)? = Pointer(Void).null)
    mmap = new size, flags, prot: prot, shared: shared, file: file, offset: offset, addr: addr
    begin
      yield mmap
    ensure
      mmap.close
    end
  end

  @pointer : UInt8*
  @size : LibC::SizeT
  @sysflags : Int32
  getter? closed = false

  def initialize(size, flags : Flags? = nil, *, @prot : Prot = Prot::ReadWrite, shared : Bool = false, file : File? = nil, offset = 0, @addr : Pointer(Void) = Pointer(Void).null)
    @size = size = LibC::SizeT.new(size)
    sysflags = (shared ? LibC::MAP_SHARED : LibC::MAP_PRIVATE)
    sysflags |= LibC::MAP_ANON if file.nil?
    sysflags |= flags.to_i if flags
    @sysflags = sysflags
    @fd = file.try(&.fd) || -1

    raise ArgumentError.new("can't specify offset without file") if file.nil? && offset > 0

    ptr = LibC.mmap(@addr, @size, @prot, @sysflags, @fd, offset)
    raise RuntimeError.from_errno("mmap size=#{size} prot=#{@prot} flags=#{@sysflags} fd=#{@fd} offset=#{offset}") if ptr == LibC::MAP_FAILED

    @pointer = ptr.as(Pointer(UInt8))
  end

  # *size* limited to Int32 for due to `Slice` limitations
  def [](idx, size) : SubRegion
    range_check idx, size
    SubRegion.new self, idx.to_i64, size.to_i32
  end

  def resize(size, moveable : Bool = true) : Nil
    check_closed

    size = LibC::SizeT.new size

    {% if LibC.has_method?(:mremap) && LibC.has_constant?(:MREMAP_MAYMOVE) %}
      flags = moveable ? LibC::MREMAP_MAYMOVE : 0

      ptr = LibC.mremap(@pointer, @size, size, flags)
      raise RuntimeError.from_errno("mremap") if ptr == LibC::MAP_FAILED
      @pointer = ptr.as(Pointer(UInt8))
      @size = size
    {% else %}
      # Attempt to enlarge anon memory by mapping new region and copying
      if @fd == -1 && @addr.null?
        ptr = LibC.mmap(nil, size, @prot, @sysflags, @fd, 0)
        raise RuntimeError.from_errno("mmap size=#{size} prot=#{@prot} flags=#{@sysflags} fd=#{@fd}") if ptr == LibC::MAP_FAILED

        begin
          to_slice.copy_to Slice.new(ptr.as(Pointer(UInt8)), size)
        rescue ex
          r = LibC.munmap ptr, size
          # Too many errors to recover from
          abort("munmap failed after failed copy") if r != 0
          raise ex
        else
          # unmap old region
          r = LibC.munmap @pointer, @size
          # Too many errors to recover from
          abort("munmap old region failed") if r != 0

          @pointer = ptr.as(Pointer(UInt8))
          @size = size
        end
      else
        raise NotImplementedError.new("missing mremap")
      end
    {% end %}
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
