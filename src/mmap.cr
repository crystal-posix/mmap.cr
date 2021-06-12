lib LibC
  fun mremap(oaddr : Void*, osize : SizeT, nsize : SizeT, flags : Int) : Void*
end

class Mmap
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
    mmap = new *args
    begin
      yield mmap
    ensure
      mmap.close
    end
  end

  @ptr : UInt8*
  @size : LibC::SizeT
  getter? closed = false

  def initialize(size, flags = nil, *, prot : Prot = Prot::Read | Prot::Write, shared : Bool = false, file : File? = nil, offset = 0)
    @size = size = LibC::SizeT.new(size)
    flags2 = (shared ? LibC::MAP_SHARED : LibC::MAP_PRIVATE)
    flags2 |= LibC::MAP_ANON if file.nil?
    flags2 |= flags if flags
    fd = file.try(&.fd) || -1

    ptr = LibC.mmap(nil, @size, prot, flags2, fd, offset)
    raise RuntimeError.from_errno("mmap") if ptr == LibC::MAP_FAILED

    @ptr = ptr.as(Pointer(UInt8))
  end

  delegate :[], :[]=, to: to_slice

  def resize(size, moveable = false) : Nil
    size = LibC::SizeT.new size
    flags = moveable ? raise("notimpl") : 0

    ptr = LibC.mremap(@ptr, @size, size, flags)
    raise RuntimeError.from_errno("mremap") if ptr == LibC::MAP_FAILED

    @ptr = ptr.as(Pointer(UInt8))
    @size = size
  end

  def close : Nil
    return if closed?
    @closed = true

    r = LibC.munmap @ptr, @size
    raise RuntimeError.from_errno("munmap") if r != 0
  end

  def to_slice : Bytes
    Slice.new @ptr, @size
  end

  def finalize
    close
  end
end
