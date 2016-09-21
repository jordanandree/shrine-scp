require "test_helper"
require "ostruct"

describe Shrine::Storage::Rsync do
  before do
    @whoami = `whoami`
    @storage = Shrine::Storage::Rsync.new(ssh_host: "#{@whoami}@127.0.0.1")
    @io = FakeIO.new("file")
  end

  describe "#initialize" do
    it "should configure :host" do
      assert_equal ::Rsync.host, "#{@whoami}@127.0.0.1"
    end
  end

  describe "#upload" do
    it "replaces the id with an URL" do
      @storage.upload @io, "foo"
      assert File.exists?("./tmp/foo")
    end
  end
end
