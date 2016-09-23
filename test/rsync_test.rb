require "test_helper"
require "ostruct"

describe Shrine::Storage::Rsync do
  let(:directory) { File.join(FileUtils.pwd, "tmp/downloads") }
  let(:io) { FakeIO.new("file") }

  describe "#initialize" do
    it "should make the tmp dir" do
      assert File.directory?(Shrine::Storage::Rsync::TMP_DIR)
    end
  end

  describe "#upload" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/uploads")
      storage = Shrine::Storage::Rsync.new(directory: directory, options: ["-q"])
      storage.upload io, "foo"
    end

    it "saves io to tmp path" do
      assert File.exist?("./tmp/foo")
    end

    it "copies to remote directory" do
      assert File.exist?("./tmp/uploads/foo")
    end
  end

  describe "#download" do
    it "downloads to tmp dir" do
      directory = File.join(FileUtils.pwd, "tmp/downloads")
      storage = Shrine::Storage::Rsync.new(directory: directory, options: ["-q"])
      storage.upload io, "foo"
      storage.download "foo"
      assert File.exist?("./tmp/foo")
    end
  end

  describe "#url" do
    it "should return id with minimal config" do
      storage = Shrine::Storage::Rsync.new(directory: directory, options: ["-q"])
      storage.upload io, "foo"
      assert_equal storage.url("foo"), "foo"
    end

    it "should return host and prefix with id" do
      storage = Shrine::Storage::Rsync.new(
        directory: directory,
        host: "http://example.com",
        prefix: "bar",
        options: ["-q"]
      )
      storage.upload io, "foo"
      assert_equal storage.url("foo"), "http://example.com/bar/foo"
    end
  end
end
