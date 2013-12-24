require 'vcs_toolkit/exceptions'

module VCSToolkit
  ##
  # This class is used to implement a custom storage provider for
  # files.
  #
  # The methods are compatible with the interface of Hash so that
  # a simple Hash can be used instead of a full-featured file manager.
  #
  class FileStore
    include Enumerable

    ##
    # Implement this to store a specific file in persistent storage.
    #
    def store(file_name, blob)
      raise NotImplementedError, 'You must implement FileStore#store'
    end

    ##
    # Implement this to retrieve a file with the specified name.
    #
    def fetch(file_name)
      raise NotImplementedError, 'You must implement FileStore#fetch'
    end

    ##
    # Implement this to detect wether a file with that name exists.
    #
    def key?(file_name)
      raise NotImplementedError, 'You must implement FileStore#key?'
    end

    ##
    # Implement this to enumerate over all files.
    #
    # The order of enumeration doesn't matter.
    #
    def each
      raise NotImplementedError, 'You must implement FileStore#each'
    end
  end
end