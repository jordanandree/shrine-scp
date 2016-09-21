require "test_helper"
require "ostruct"

describe Shrine::Storage::Rsync do
  before do
    @io = FakeIO.new("file")
  end

  describe "#initialize" do
    it "should make the tmp dir" do
      assert File.directory?(Shrine::Storage::Rsync::TMP_DIR)
    end
  end

  describe "#upload" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/uploads")
      @storage = Shrine::Storage::Rsync.new(directory: directory, options: ["-q"])
      @storage.upload @io, "foo"
    end

    it "saves io to tmp path" do
      assert File.exist?("./tmp/foo")
    end

    it "copies to remote directory" do
      assert File.exist?("./tmp/uploads/foo")
    end
  end

  describe "#download" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/downloads")
      @storage = Shrine::Storage::Rsync.new(directory: directory, options: ["-q"])
      @storage.upload @io, "foo"
    end

    it "downloads to tmp dir" do
      @storage.download "foo"
      assert File.exist?("./tmp/foo")
    end
  end
end
