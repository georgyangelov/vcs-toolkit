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
    # Implement this to enumerate over all files.
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

    def files(path='')
      enum_for(:each_file, path)
    end

    def directories(path='')
      enum_for(:each_directory, path)
    end
  end
end