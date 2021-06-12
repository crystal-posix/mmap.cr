require "./spec_helper"
require "../src/mmap"

describe Mmap do
  it "maps anon memory" do
    initial_size = 2048
    Mmap::Region.open(initial_size) do |mmap|
      mmap.to_slice[7] = 7_u8
      sub1 = mmap[5, 10]
      sub1.to_slice[2].should eq 7_u8
      sub2 = sub1[2, 1]
      sub2.to_slice[0].should eq 7_u8

      expect_raises IndexError do
        mmap[initial_size, 1]
      end

      # Test resizing
      new_size = initial_size * 2
      mmap.resize new_size
      mmap[initial_size, 1]
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
    mmap = Mmap::Region.new(8192, prot: Mmap::Prot::None)
#    Mmap::Region.open(8192, prot: Mmap::Prot::None) do |mmap|
      sub = mmap[4096, 4096]
      sub.mprotect Mmap::Prot.flags(Read, Write)
      sub.to_slice[0] = 1_u8
#      mmap.to_slice[0] = 1_u8 # Crash
 #   end
    mmap.close
  end

  pending "madvise" do
  end

  pending "msync" do
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

      mmap = Mmap::Region.new(8192, shared: true, file: file)
      mmap.to_slice[99] = 1_u8
      mmap.msync
      mmap.close

      file.gets_to_end.to_slice[99].should eq 1_u8
    end
  end
end
