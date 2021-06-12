lib LibC
  {% if flag?(:linux) %}
    MS_SYNC = 4
    MREMAP_MAYMOVE = 1
  {% end %}

  fun mremap(oaddr : Void*, osize : SizeT, nsize : SizeT, flags : Int) : Void*
  fun msync(addr : Void*, size : SizeT, flags : Int) : Int
  fun mlock(addr : Void*, size : SizeT) : Int
  fun munlock(addr : Void*, size : SizeT) : Int
end
