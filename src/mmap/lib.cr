lib LibC
  {% if flag?(:linux) %}
    MS_SYNC        = 4
    MREMAP_MAYMOVE = 1

    MAP_DONTFORK   = 10
    MAP_DONTDUMP   = 16
    MAP_WIPEONFORK = 18

    MAP_HUGETLB  = 0x040000
    MAP_HUGE_2MB = 21 << 26
    MAP_HUGE_1GB = 30 << 26
  {% else %}
    MAP_DONTFORK   = 0
    MAP_DONTDUMP   = 0
    MAP_WIPEONFORK = 0

    MAP_HUGETLB  = 0
    MAP_HUGE_2MB = 0
    MAP_HUGE_1GB = 0
  {% end %}

  fun mremap(oaddr : Void*, osize : SizeT, nsize : SizeT, flags : Int) : Void*
  fun msync(addr : Void*, size : SizeT, flags : Int) : Int
  fun mlock(addr : Void*, size : SizeT) : Int
  fun munlock(addr : Void*, size : SizeT) : Int
end
