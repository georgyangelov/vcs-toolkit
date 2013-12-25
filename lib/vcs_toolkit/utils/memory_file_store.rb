require 'vcs_toolkit/file_store'

module VCSToolkit
  module Utils

    class MemoryFileStore < FileStore
      def initialize(file_hash = {})
        @files = {}

        file_hash.each do |path, content|
          store path, content
        end
      end

      def store(path, content)
        path = sanitize_path(path, false)

        if path.end_with? '/'
          raise 'You can store only files. The directories will be infered from the path'
        end

        @files[path] = content
      end

      def fetch(path)
        @files.fetch sanitize_path(path, false)
      end

      def file?(path)
        @files.key? sanitize_path(path, false)
      end

      def directory?(path)
        return false if file? path

        path = sanitize_path(path, true)

        @files.keys.any? do |file_path|
          file_path.start_with? path
        end
      end

      def each_file(path='')
        @files.each do |file_path, file|
          name = file_path.sub(path, '').sub(/^\/+/, '')

          if file_path.start_with?(path) and not name.empty? and not name.include?('/')
            yield name
          end
        end
      end

      def each_directory(path='')
        yielded_dirs = {}

        path = sanitize_path(path, true) + '/' unless path.empty?

        @files.each do |file_path, _|
          name = file_path.sub(path, '')

          if file_path.start_with?(path) and not name.empty? and name.include?('/')
            name = name.split('/').first

            yield name unless name.empty? or yielded_dirs.key? name
            yielded_dirs[name] = true
          end
        end
      end

      private

      def sanitize_path(path, remove_trailing_slash)
        path.gsub(/\/+|\\+/, '/').gsub(/^\//, '')

        if remove_trailing_slash
          path.sub(/\/$/, '')
        else
          path
        end
      end
    end

  end
end