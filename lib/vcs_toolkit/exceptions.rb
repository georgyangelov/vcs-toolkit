module VCSToolkit
  class VCSToolkitError < StandardError
  end

  class InvalidObjectError < VCSToolkitError
  end

  class UnknownLabelError < VCSToolkitError
  end
end