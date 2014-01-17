require 'vcs_toolkit/exceptions'

module VCSToolkit
  ##
  # This class is used to implement a custom storage provider for
  # files.
  #
  class FileStore
    ##
    # Implement this to store a specific file in persistent storage.
    #
    def store(path, blob)
      raise NotImplementedError, 'You must implement FileStore#store'
    end

    ##
    # Implement this to retrieve a file with the specified name.
    #
    def fetch(path)
      raise NotImplementedError, 'You must implement FileStore#fetch'
    end

    ##
    # Implement this to delete the specified file
    #
    def delete_file(path)
      raise NotImplementedError, 'You must implement FileStore#delete_file'
    end

    ##
    # Implement this to delete the specified directory.
    # This method will be called only on empty directories.
    # Use #delete if you want to recursively delete a directory.
    #
    def delete_dir(path)
      raise NotImplementedError, 'You must implement FileStore#delete_dir'
    end

    ##
    # Implement this to detect wether a file with that name exists.
    #
    def file?(path)
      raise NotImplementedError, 'You must implement FileStore#file?'
    end

    ##
    # Implement this to detect wether a directory with that name exists.
    #
    def directory?(path)
      raise NotImplementedError, 'You must implement FileStore#directory?'
    end

    ##
    # Implement this to compare a file and a blob object.
    # It should return boolean value to indicate wether the file is different.
    #
    # The hash algorithm should be the same one used in `Objects::*`.
    #
    def changed?(path, blob)
      raise NotImplementedError, 'You must implement FileStore#changed?'
    end

    ##
    # Implement this to enumerate over all files in the given directory.
    #
    # The order of enumeration doesn't matter.
    #
    def each_file(path='')
      raise NotImplementedError, 'You must implement FileStore#each_file'
    end

    ##
    # Implement this to enumerate over all files.
    #
    # The order of enumeration doesn't matter.
    #
    def each_directory(path='')
      raise NotImplementedError, 'You must implement FileStore#each_directory'
    end

    def exist?(path)
      file?(path) or directory?(path)
    end

    def files(path='', ignore: [])
      enum_for(:each_file, path).reject { |file| ignored? file, ignore }
    end

    def directories(path='', ignore: [])
      enum_for(:each_directory, path).reject { |file| ignored? file, ignore }
    end

    def all_files(path='', ignore: [])
      enum_for :yield_all_files, path, ignore: ignore
    end

    def delete(path)
      if directory? path
        files(path).each do |file|
          delete_file File.join(path, file)
        end

        directories(path).each do |directory|
          delete File.join(path, directory)
        end

        delete_dir path
      else
        delete_file path
      end
    end

    private

    def yield_all_files(path='', ignore: [], &block)
      files(path).reject { |path| ignored? path, ignore }.each &block

      directories(path).each do |dir_name|
        dir_path = File.join(path, dir_name).sub(/^\/+/, '')

        all_files(dir_path).each do |file|
          file_path = File.join(dir_name, file)

          yield file_path unless ignored?(file_path, ignore) or ignored?(file.split('/').last, ignore)
        end
      end
    end

    def ignored?(path, ignores)
      ignores.any? do |ignore|
        if ignore.is_a? Regexp
          ignore =~ path
        else
          ignore == path
        end
      end
    end
  end
end