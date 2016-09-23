require "test_helper"
require "ostruct"

describe Shrine::Storage::Scp do
  let(:directory) { File.join(FileUtils.pwd, "tmp") }
  let(:io) { FakeIO.new("file") }
  let(:ssh) { "#{`whoami`.chomp}@127.0.0.1" }

  describe "#upload" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/uploads")
      @storage = Shrine::Storage::Scp.new(directory: directory)
    end

    it "saves io to tmp path" do
      tmp = @storage.upload io, "foo.png"
      assert File.exist?(tmp.path)
    end

    it "copies to remote directory" do
      @storage.upload io, "foo.txt"
      assert File.exist?("./tmp/uploads/foo.txt")
    end

    it "should upload to prefix" do
      FileUtils.mkdir_p(File.join(FileUtils.pwd, "tmp/uploads/sub"))
      @storage.instance_variable_set "@prefix", "sub"
      @storage.upload io, "foo.mp4"
      assert File.exist?("./tmp/uploads/sub/foo.mp4")
    end

    it "should set custom permissions" do
      @storage.instance_variable_set "@permissions", 0644
      @storage.upload io, "foo.rtf"
      stat = File.stat("./tmp/uploads/foo.rtf")
      assert_equal format("%o", stat.mode), "100644"
    end
  end

  describe "#download" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/downloads")
      storage = Shrine::Storage::Scp.new(directory: directory)
      storage.upload io, "foo.mov"
      @tmp = storage.download "foo.mov"
    end

    it "downloads to tmp dir" do
      assert File.exist?(@tmp.path)
    end
  end

  describe "#open" do
    before do
      @storage = Shrine::Storage::Scp.new(directory: directory)
      @storage.upload io, "bar"
    end

    it "returns a file handler" do
      assert_equal @storage.open("bar").read, "file"
    end
  end

  describe "#exists?" do
    it "returns true when file is local" do
      @storage = Shrine::Storage::Scp.new(directory: directory)
      @storage.upload io, "baz"
      assert @storage.exists?("baz")
    end

    it "returns false if file does not exist" do
      @storage = Shrine::Storage::Scp.new(directory: directory)
      refute @storage.exists?("barf")
    end

    it "returns true when file is remote" do
      skip("No remote testing on CI") if ENV["CI"]
      @storage = Shrine::Storage::Scp.new(directory: directory, ssh_host: ssh)
      @storage.upload io, "baz"
      assert @storage.exists?("baz")
    end
  end

  describe "#delete" do
    it "returns true when file is local" do
      @storage = Shrine::Storage::Scp.new(directory: directory)
      @storage.upload io, "hodor"
      assert @storage.delete("hodor")
      refute File.exist? "./tmp/hodor"
    end

    it "returns true when file is local" do
      skip("No remote testing on CI") if ENV["CI"]
      @storage = Shrine::Storage::Scp.new(directory: directory, ssh_host: ssh)
      @storage.upload io, "gollum"
      assert @storage.delete("gollum")
      refute File.exist? "./tmp/gollum"
    end
  end

  describe "#clear!" do
    before do
      directory = File.join(FileUtils.pwd, "tmp/clear")
      FileUtils.mkdir_p(directory)
      @storage = Shrine::Storage::Scp.new(directory: directory)
      @storage.upload io, "frodo"
      @storage.clear!
    end

    it "removes all files" do
      refute File.exist? "./tmp/clear/frodo"
    end
  end

  describe "#url" do
    it "should return id with minimal config" do
      storage = Shrine::Storage::Scp.new(directory: directory)
      storage.upload io, "foo.bmp"
      assert_equal storage.url("foo.bmp"), "foo.bmp"
    end

    it "should return host and prefix with id" do
      FileUtils.mkdir_p(File.join(FileUtils.pwd, "tmp/folder"))
      storage = Shrine::Storage::Scp.new(
        directory: directory,
        host: "http://example.com",
        prefix: "folder",
        options: ["-q"]
      )
      storage.upload io, "foo.tar.gz"
      assert_equal storage.url("foo.tar.gz"), "http://example.com/folder/foo.tar.gz"
    end
  end
end
