require "./spec_helper"
require "../src/mmap"

# Check restricting type to Module
private def can_to_slice(mmap : Mmap) : Bytes
  mmap.to_slice
end

describe Mmap do
  it "maps anon memory" do
    initial_size = 2048
    Mmap::Region.open(initial_size) do |mmap|
      can_to_slice(mmap)[7] = 7_u8
      sub1 = mmap[5, 10]
      can_to_slice(sub1)[2].should eq 7_u8
      sub2 = sub1[2, 1]
      can_to_slice(sub2)[0].should eq 7_u8

      expect_raises IndexError do
        mmap[initial_size, 1]
      end

      # Test resizing
      new_size = initial_size * 2
      mmap.resize new_size
      mmap[initial_size, 1]
      can_to_slice(sub1)[2].should eq 7_u8
    end
  end

  it "no access after close" do
    mmap = Mmap::Region.new 1024
    sub = mmap[5, 10]
    mmap.close

    expect_raises Mmap::Error::Closed do
      mmap.to_slice
    end

    expect_raises Mmap::Error::Closed do
      sub.to_slice
    end
  end

  it "mprotect" do
    Mmap::Region.open(8192, prot: Mmap::Prot::None) do |mmap|
      sub = mmap[4096, 4096]
      sub.mprotect Mmap::Prot.flags(Read, Write)
      sub.to_slice[0] = 1_u8
      #      mmap.to_slice[0] = 1_u8 # Crash
    end
  end

  pending "madvise" do
  end

  it "guard_page" do
    Mmap::Region.open(8192) do |mmap|
      mmap.guard_page
      # TODO: trap
      #      mmap.to_slice[0] = 1_u8
    end
  end

  it "crypto_key" do
    Mmap::Region.open(8192) do |mmap|
      mmap.crypto_key
      mmap.to_slice[0] = 1_u8
    end
  end

  it "mlock" do
    Mmap::Region.open(8192) do |mmap|
      mmap.mlock
      mmap.munlock
    end
  end

  it "write file with msync" do
    File.open("extend.tmp", "w+") do |file|
      file.truncate 100

      Mmap::Region.open(8192, shared: true, file: file) do |mmap|
        mmap.to_slice[99] = 1_u8
        mmap.msync
      end

      file.gets_to_end.to_slice[99].should eq 1_u8
    end
  end
end
