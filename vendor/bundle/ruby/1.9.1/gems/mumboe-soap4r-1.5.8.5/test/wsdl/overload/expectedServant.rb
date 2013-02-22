require 'default.rb'

class OverloadServicePortType
  # SYNOPSIS
  #   methodAlpha(in0, in1, in2)
  #
  # ARGS
  #   in0             C_String - {http://www.w3.org/2001/XMLSchema}string
  #   in1             C_String - {http://www.w3.org/2001/XMLSchema}string
  #   in2             C_String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   methodAlphaReturn Long - {http://www.w3.org/2001/XMLSchema}long
  #
  def methodAlpha(in0, in1, in2)
    p [in0, in1, in2]
    raise NotImplementedError.new
  end

  # SYNOPSIS
  #   methodAlpha_2(in0, in1)
  #
  # ARGS
  #   in0             C_String - {http://www.w3.org/2001/XMLSchema}string
  #   in1             C_String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   methodAlphaReturn Long - {http://www.w3.org/2001/XMLSchema}long
  #
  def methodAlpha_2(in0, in1)
    p [in0, in1]
    raise NotImplementedError.new
  end
end

