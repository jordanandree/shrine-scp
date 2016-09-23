require "shrine"

require "fileutils"
require "pathname"
require "tempfile"

class Shrine
  module Storage
    class Scp
      PWD     = Pathname.new(File.expand_path("../../../../", __FILE__)).freeze
      TMP_DIR = PWD.join("tmp").freeze

      attr_reader :directory, :ssh_host, :host, :prefix, :options

      def initialize(directory:, ssh_host: nil, host: nil, prefix: nil, options: [])
        # Initializes a storage for uploading via scp.
        #
        # :directory
        # :  the path where files will be transferred to
        #
        # :ssh_host
        # :  optional user@hostname for remote scp transfers over ssh
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
        # :  Additional arguments specific to scp
        #    https://linux.die.net/man/1/scp
        @directory = directory.chomp(File::SEPARATOR)
        @prefix    = prefix.chomp(File::SEPARATOR) if prefix
        @host      = host.chomp(File::SEPARATOR) if host
        @ssh_host  = ssh_host
        @options   = options

        FileUtils.mkdir_p(TMP_DIR.to_s) unless TMP_DIR.exist?
      end

      def upload(io, id, **)
        local_path = store_tmp(io, id)
        scp_up(local_path)
      end

      def download(id)
        io = scp_down(id)

        tempfile = Tempfile.new(["scp", File.extname(id)], binmode: true)
        IO.copy_stream(io, tempfile)
        tempfile.tap(&:open)
        tempfile
      end

      def open(id)
        # noop
      end

      def exists?(id)
        # noop
      end

      def url(id, **_options)
        [host, prefix, id].compact.join(File::SEPARATOR)
      end

      def delete(id)
        # noop
      end

      def clear!
        # noop
      end

      private

        def scp_up(local_file_path)
          scp_transfer(source: local_file_path, destination: scp_host)
        end

        def scp_down(id)
          source = File.join(scp_host.chomp("/"), id)

          tmp_path(id) if scp_transfer(source: source, destination: tmp_path(id))
        end

        def scp_transfer(source:, destination:)
          command = [scp_bin, scp_options, source, destination].join(" ")
          system(command)
        end

        def scp_host
          ssh_host ? "#{ssh_host}:#{directory}" : directory
        end

        def scp_bin
          scp_bin = `which scp`.chomp
          raise "scp could not be found." if scp_bin.empty?
          scp_bin
        end

        def scp_options
          options.join(" ")
        end

        def store_tmp(io, id)
          path = tmp_path(id)
          IO.copy_stream(io, path)
          path
        end

        # Returns the tmp path to the file.
        def tmp_path(id)
          TMP_DIR.join(id.gsub("/", File::SEPARATOR))
        end
    end
  end
end
