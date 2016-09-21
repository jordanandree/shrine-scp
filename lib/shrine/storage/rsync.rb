require "shrine"
require "rsync"

require "fileutils"
require "pathname"

class Shrine
  module Storage
    class Rsync
      TMP_DIR = Pathname.new(File.expand_path("../../../../tmp", __FILE__))

      def initialize(directory: nil, ssh_host: nil, host: nil, prefix: nil, args: [])
        # Initializes a storage for uploading via rsync.
        #
        # :directory
        # :  the path where files will be transferred to
        #
        # :ssh_host
        # :  optional user@hostname for remote rsync transfers over ssh
        #
        # :host
        # :  URLs will by default be relative if `:prefix` is set, and you
        #    can use this option to set a CDN host (e.g. `//abc123.cloudfront.net`).
        # :prefix
        # :  The directory relative to `directory` to which files will be stored,
        #    and it is included in the URL.
        @directory = directory
        @prefix = prefix
        @host = host
        @ssh_host = ssh_host
        @args = args

        ::Rsync.configure do |c|
          c.host = @ssh_host
        end if @ssh_host
      end

      def upload(io, id, **)
        store_tmp(io, id)     
      end

      def download(id)
      end

      def open(id)
      end

      def exists?(id)
      end

      def url(id, **options)
        id
      end

      def delete(id)
        # noop
      end

      def clear!
        # noop
      end

      private

        def store_tmp(io, id)
          IO.copy_stream(io, tmp_path!(id))
        end

        # Returns the tmp path to the file.
        def tmp_path!(id)
          FileUtils.mkdir_p(TMP_DIR.to_s) unless TMP_DIR.exist?
          TMP_DIR.join(id.gsub("/", File::SEPARATOR))
        end
    end
  end
end
