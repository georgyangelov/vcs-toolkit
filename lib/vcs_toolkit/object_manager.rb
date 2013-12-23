require 'vcs_toolkit/exceptions'

module VCSToolkit
  ##
  # This class is used to implement a custom storage provider for
  # objects.
  #
  # The methods are compatible with the interface of Hash so that
  # a simple Hash can be used instead of a full-featured object manager.
  #
  class ObjectManager
    include Enumerable

    ##
    # Implement this to store a specific object in persistent storage.
    #
    # object_id is here for compatibility with Hash
    #
    def store(object_id, object)
      raise NotImplementedError, 'You must implement ObjectManager#store'
    end

    ##
    # Implement this to retrieve an object with the specified object_id.
    # It should detect the object type and instantiate the specific
    # object class (or a subclass of it).
    #
    def fetch(object_id)
      raise NotImplementedError, 'You must implement ObjectManager#fetch'
    end

    ##
    # Implement this to detect wether a object with that object_id exists.
    #
    def key?(object_id)
      raise NotImplementedError, 'You must implement ObjectManager#key?'
    end

    ##
    # Implement this to enumerate over all objects that
    # have Object#named? set to true.
    # Even enumeration of all objects is possible, but is not
    # neccessary.
    #
    # The order of enumeration doesn't matter.
    #
    def each
      raise NotImplementedError, 'You must implement ObjectManager#each'
    end
  end
end