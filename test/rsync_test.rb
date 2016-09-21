require "test_helper"
require "ostruct"

describe Shrine::Storage::Rsync do
  before do
    @directory = File.join(FileUtils.pwd, "tmp/uploads")
    @storage = Shrine::Storage::Rsync.new(directory: @directory, options: ["-q"])
    @io = FakeIO.new("file")
  end

  describe "#initialize" do
    it "should make the tmp dir" do
      assert File.directory?(Shrine::Storage::Rsync::TMP_DIR)
    end
  end

  describe "#upload" do
    before do
      @storage.upload @io, "foo"
    end

    it "saves io to tmp path" do
      assert File.exists?("./tmp/foo")
    end

    it "copies to remote directory" do
      assert File.exists?("./tmp/uploads/foo")
    end
  end
end
