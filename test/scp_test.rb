require "test_helper"
require "ostruct"

describe Shrine::Storage::Scp do
  let(:directory) { File.join(FileUtils.pwd, "tmp/downloads") }
  let(:io) { FakeIO.new("file") }

  describe "#upload" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/uploads")
      @storage = Shrine::Storage::Scp.new(directory: directory, options: ["-q"])
    end

    it "saves io to tmp path" do
      tmp = @storage.upload io, "foo.png"
      assert File.exist?(tmp.path)
    end

    it "copies to remote directory" do
      @storage.upload io, "foo.txt"
      assert File.exist?("./tmp/uploads/foo.txt")
    end

    it "should set custom permissions" do
      @storage.instance_variable_set "@permissions", 0644
      @storage.upload io, "foo.rtf"
      stat = File.stat("./tmp/uploads/foo.rtf")
      assert_equal format("%o", stat.mode), "100644"
    end
  end

  describe "#download" do
    it "downloads to tmp dir" do
      directory = File.join(FileUtils.pwd, "tmp/downloads")
      storage = Shrine::Storage::Scp.new(directory: directory, options: ["-q"])
      storage.upload io, "foo.mov"
      tmp = storage.download "foo.mov"
      assert File.exist?(tmp.path)
    end
  end

  describe "#url" do
    it "should return id with minimal config" do
      storage = Shrine::Storage::Scp.new(directory: directory, options: ["-q"])
      storage.upload io, "foo.bmp"
      assert_equal storage.url("foo.bmp"), "foo.bmp"
    end

    it "should return host and prefix with id" do
      storage = Shrine::Storage::Scp.new(
        directory: directory,
        host: "http://example.com",
        prefix: "bar",
        options: ["-q"]
      )
      storage.upload io, "foo.tar.gz"
      assert_equal storage.url("foo.tar.gz"), "http://example.com/bar/foo.tar.gz"
    end
  end
end
