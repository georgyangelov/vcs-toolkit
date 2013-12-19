require 'vcs_toolkit/exceptions'

module VCSToolkit

  class ObjectManager
    def initialize
      raise NotImplementedError('The ObjectManager class should be inherited and its methods overriden')
    end

    def store(object_id)
      raise NotImplementedError('You must implement ObjectManager#store')
    end

    def retrieve(object_id)
      raise NotImplementedError('You must implement ObjectManager#retrieve')
    end

    def include?(object_id)
      raise NotImplementedError('You must implement ObjectManager#include?')
    end
  end

end