module Mmap
  lib C
    {% if flag?(:linux) %}
      MS_SYNC        = 4
      MREMAP_MAYMOVE = 1

      MAP_HUGETLB  = 0x040000
      MAP_HUGE_2MB = 21 << 26
      MAP_HUGE_1GB = 30 << 26

      MADV_DONTFORK   = 10
      MADV_DONTDUMP   = 16
      MADV_WIPEONFORK = 18
      MADV_HUGEPAGE   = 14
      MADV_NOHUGEPAGE = 15
    {% elsif flag?(:darwin) %}
      # BUG: missing value
      MS_SYNC = 0

      MAP_HUGETLB  = 0
      MAP_HUGE_2MB = 0
      MAP_HUGE_1GB = 0

      MADV_DONTFORK   = 0
      MADV_DONTDUMP   = 0
      MADV_WIPEONFORK = 0
      MADV_HUGEPAGE   = 0
      MADV_NOHUGEPAGE = 0
    {% else %}
      MAP_HUGETLB  = 0
      MAP_HUGE_2MB = 0
      MAP_HUGE_1GB = 0

      MADV_DONTFORK   = 0
      MADV_DONTDUMP   = 0
      MADV_WIPEONFORK = 0
      MADV_HUGEPAGE   = 0
      MADV_NOHUGEPAGE = 0
    {% end %}

    fun mremap(oaddr : Void*, osize : LibC::SizeT, nsize : LibC::SizeT, flags : LibC::Int) : Void*
    fun msync(addr : Void*, size : LibC::SizeT, flags : LibC::Int) : LibC::Int
    fun mlock(addr : Void*, size : LibC::SizeT) : LibC::Int
    fun munlock(addr : Void*, size : LibC::SizeT) : LibC::Int
  end
end
