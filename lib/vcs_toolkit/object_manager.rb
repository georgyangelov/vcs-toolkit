require 'vcs_toolkit/exceptions'

module VCSToolkit

  class ObjectManager
    def initialize
      raise 'The ObjectManager class should be inherited and its methods overriden'
    end

    def store(id)
      raise 'You must implement ObjectManager#store'
    end

    def retrieve(id)
      raise 'You must implement ObjectManager#retrieve'
    end

    def include?(id)
      raise 'You must implement ObjectManager#include?'
    end
  end

end