require "./*"

module Mmap
  class Error < Exception
    class Closed < Error
    end
  end

  @[Flags]
  enum Prot
    None  = LibC::PROT_NONE
    Read  = LibC::PROT_READ
    Write = LibC::PROT_WRITE
    Exec  = LibC::PROT_EXEC
  end

  @[Flags]
  enum Flags
    Fixed = LibC::MAP_FIXED
    #  = LibC::MAP_32BIT
    #  = LibC::MAP_FIXED_NO_REPLACE(Linux) vs EXCL(BSD)
    # Hugetlb = LibC::MAP_HUGETLB # Linux only
    # Hugetlb_2mb = LibC::MAP_HUGETLB_2MB(Linux requires HUGETLB)
    # Hugetlb_1gb = LibC::MAP_HUGETLB_1GB(Linux requires HUGETLB)
    # Stack = LibC::MAP_STACK # Linux: flag exists but not implemented
    # Sync = LibC::MAP_SYNC # Linux only
    # NoSync = LibC::MAP_NOSYNC # BSD only
    # NoCore = LibC::MAP_NOCORE # BSD only
    # Populate = LibC::MAP_POPULATE # Linux only
    # Nonblock = LibC::MAP_NONBLOCK # Linux only (requires POPULATE) - currently turns POPULATE in to noop
    # Possibly same as Linux POPULATE & NONBLOCK but functional
    # PreFaultRead = LibC::MAP_PREFAULT_READ # BSD only
  end

  def self.open(*args)
    mmap = Region.new *args
    begin
      yield mmap
    ensure
      mmap.close
    end
  end

  def mprotect(prot : Prot) : Nil
    ptr = range_checked_pointer(0, @size)
    r = LibC.mprotect(ptr, @size, prot)
    raise RuntimeError.from_errno("mprotect") if r != 0
  end

  def madvise() : Nil
    ptr = range_checked_pointer(0, @size)
    r = LibC.madvise(ptr, @size, )
    raise RuntimeError.from_errno("madvise") if r != 0
  end

  def msync : Nil
    ptr = range_checked_pointer(0, @size)
    r = LibC.msync(ptr, @size, LibC::MS_SYNC)
    raise RuntimeError.from_errno("msync") if r != 0
  end

  def to_slice : Bytes
    Slice.new to_unsafe, @size
  end

  abstract def [](idx, size) : SubRegion
  abstract def to_unsafe

  protected abstract def range_checked_pointer(idx, size = 0) : Pointer(UInt8)
end

require "./*"
