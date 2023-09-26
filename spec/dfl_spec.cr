require "./spec_helper"

describe DFL do
  it "write empty dfl" do
    dfl = DFL.new
    dfl.write("test.dfl")
    dfl = DFL.read("./test.dfl")
    File.delete("./test.dfl")
  end
end
