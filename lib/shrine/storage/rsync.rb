require "shrine"

require "fileutils"
require "pathname"

class Shrine
  module Storage
    class Rsync
      PWD     = Pathname.new(File.expand_path("../../../../", __FILE__)).freeze
      TMP_DIR = PWD.join("tmp").freeze

      attr_reader :directory, :ssh_host, :host, :prefix, :options

      def initialize(directory:, ssh_host: nil, host: nil, prefix: nil, options: [])
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
        #
        # :prefix
        # :  The directory relative to `directory` to which files will be stored,
        #    and it is included in the URL.
        #
        # :options
        # :  Additional arguments specific to rsync
        #    https://linux.die.net/man/1/rsync
        @directory = directory
        @prefix    = prefix
        @host      = host
        @ssh_host  = ssh_host
        @options   = options

        FileUtils.mkdir_p(TMP_DIR.to_s) unless TMP_DIR.exist?
      end

      def upload(io, id, **)
        local_path = store_tmp(io, id)
        rsync(local_path)
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

        def rsync(local_file_path)
          command = [rsync_bin, rsync_options, rsync_host, local_file_path].join(" ")
          system(command)
        end

        def rsync_host
          ssh_host ? "#{ssh_host}:#{directory}" : directory
        end

        def rsync_bin
          rsync_bin = `which rsync`.chomp
          raise "rsync could not be found." if rsync_bin.empty?
          rsync_bin
        end

        def rsync_options
          options.join(" ")
        end

        def store_tmp(io, id)
          path = tmp_path!(id)
          IO.copy_stream(io, path)
          path
        end

        # Returns the tmp path to the file.
        def tmp_path!(id)
          TMP_DIR.join(id.gsub("/", File::SEPARATOR))
        end
    end
  end
end
