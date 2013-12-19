require 'vcs_toolkit/objects/object'

module VCSToolkit
  module Objects

    class File < Object
      attr_reader :content

      def initialize(object_id, content)
        super(object_id)
        
        @content = content
      end
    end

  end
end