#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = OverloadServicePortType.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

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
in0 = in1 = in2 = nil
puts obj.methodAlpha(in0, in1, in2)

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
in0 = in1 = nil
puts obj.methodAlpha_2(in0, in1)


