lib LibC
  {% if flag?(:linux) %}
    MS_SYNC = 4
  {% end %}

  fun mremap(oaddr : Void*, osize : SizeT, nsize : SizeT, flags : Int) : Void*
  fun msync(addr : Void*, size : SizeT, flags : Int) : Int
end
