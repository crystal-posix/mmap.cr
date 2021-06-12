require "./spec_helper"
require "../src/mmap"

describe Mmap do
  it "maps anon memory" do
    Mmap.open(4096) do |mmap|
      mmap[0] = 1_u8
      mmap[0].should eq 1_u8

      mmap[4095] = 2_u8
      expect_raises IndexError do
        mmap[4096] = 3_u8
      end

      mmap.resize 8192
      mmap[8191] = 4_u8
    end
  end
end
