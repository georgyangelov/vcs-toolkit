require 'vcs_toolkit/exceptions'

module VCSToolkit
  ##
  # The methods are compatible with the interface of Hash
  # so a hash can be used instead of a full-featured object manager.
  class ObjectManager
    # object_id is here for compatibility with Hash
    def store(object_id, object)
      raise NotImplementedError, 'You must implement ObjectManager#store'
    end

    def fetch(object_id)
      raise NotImplementedError, 'You must implement ObjectManager#fetch'
    end

    def key?(object_id)
      raise NotImplementedError, 'You must implement ObjectManager#key?'
    end
  end
end