require "./spec_helper"
require "../src/mmap"

describe Mmap do
  it "maps anon memory" do
    initial_size = 2048
    Mmap.open(initial_size) do |mmap|
      mmap[0] = 1_u8
      mmap[0].should eq 1_u8

      mmap[initial_size - 1] = 2_u8
      expect_raises IndexError do
        mmap[initial_size] = 3_u8
      end

      new_size = initial_size * 2
      mmap.resize new_size
      mmap[new_size - 1] = 4_u8
    end
  end
end
