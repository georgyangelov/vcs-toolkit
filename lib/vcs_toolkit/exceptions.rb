module VCSToolkit
  class VCSToolkitError < StandardError
  end

  class InvalidObjectError < VCSToolkitError
  end
end