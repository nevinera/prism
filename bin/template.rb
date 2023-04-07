#!/usr/bin/env ruby

require "erb"
require "fileutils"
require "yaml"

class Param
  attr_reader :name, :options
  
  def initialize(name:, type:, **options)
    @name, @type, @options = name, type, options
  end
end

module CTypes
  def c_type
    if options[:kind]
      "yp_#{options[:kind].gsub(/(?<=.)[A-Z]/, "_\\0").downcase}"
    else
      "yp_node"
    end
  end
end


# This represents a parameter to a node that is itself a node. We pass them as
# references and store them as references.
class NodeParam < Param
  include CTypes
  
  def rbs_class = "Node"
  def java_type = "Node"
end

# This represents a parameter to a node that is itself a node and can be
# optionally null. We pass them as references and store them as references.
class OptionalNodeParam < Param
  include CTypes
  
  def rbs_class = "Node?"
  def java_type = "Node"
end

SingleNodeParam = -> (node) { NodeParam === node or OptionalNodeParam === node }

# This represents a parameter to a node that is a list of nodes. We pass them as
# references and store them as references.
class NodeListParam < Param
  def rbs_class = "Array[Node]"
  def java_type = "Node[]"
end

# This represents a parameter to a node that is a token. We pass them as
# references and store them by copying.
class TokenParam < Param
  def rbs_class = "Token"
  def java_type = "Token"
end

# This represents a parameter to a node that is a token that is optional.
class OptionalTokenParam < Param
  def rbs_class = "Token?"
  def java_type = "Token"
end

# This represents a parameter to a node that is a list of tokens.
class TokenListParam < Param
  def rbs_class = "Array[Token]"
  def java_type = "Token[]"
end

# This represents a parameter to a node that is a string.
class StringParam < Param
  def rbs_class = "String"
  def java_type = "byte[]"
end

# This represents a parameter to a node that is a location.
class LocationParam < Param
  def rbs_class = "Location"
  def java_type = "Location"
end

# This represents a parameter to a node that is a location that is optional.
class OptionalLocationParam < Param
  def rbs_class = "Location?"
  def java_type = "Location"
end

# This represents an integer parameter.
class IntegerParam < Param
  def rbs_class = "Integer"
  def java_type = "int"
end

PARAM_TYPES = {
  "node" => NodeParam,
  "node?" => OptionalNodeParam,
  "node[]" => NodeListParam,
  "string" => StringParam,
  "token" => TokenParam,
  "token?" => OptionalTokenParam,
  "token[]" => TokenListParam,
  "location" => LocationParam,
  "location?" => OptionalLocationParam,
  "integer" => IntegerParam,
  }

# This class represents a node in the tree, configured by the config.yml file in
# YAML format. It contains information about the name of the node and the
# various child nodes it contains.
class NodeType
  attr_reader :name, :type, :human, :params, :comment

  def initialize(config)
    @name = config.fetch("name")

    type = @name.gsub(/(?<=.)[A-Z]/, "_\\0")
    @type = "YP_NODE_#{type.upcase}"
    @human = type.downcase
    @params = config.fetch("child_nodes", []).map do |param|
      param_type = PARAM_TYPES[param.fetch("type")] ||
                   raise("Unknown param type: #{param["type"].inspect}")
      param_type.new(**param.transform_keys(&:to_sym))
    end
    @comment = config.fetch("comment")
  end
end

# This represents a token in the lexer. They are configured through the
# config.yml file for now, but this will probably change as we transition to
# storing semantic strings instead of the lexer tokens.
class Token
  attr_reader :name, :value, :comment

  def initialize(config)
    @name = config.fetch("name")
    @value = config["value"]
    @comment = config.fetch("comment")
  end

  def declaration
    output = []
    output << "YP_TOKEN_#{name}"
    output << " = #{value}" if value
    output << ", // #{comment}"
    output.join
  end
end

# This templates out a file using ERB with the given locals. The locals are
# derived from the config.yml file.
def template(name, locals)
  filepath = "bin/templates/#{name}.erb"
  template = File.expand_path("../#{filepath}", __dir__)
  write_to = File.expand_path("../#{name}", __dir__)

  erb = ERB.new(File.read(template), trim_mode: "-")
  erb.filename = template

  non_ruby_heading = <<~HEADING
  /******************************************************************************/
  /* This file is generated by the bin/template script and should not be        */
  /* modified manually. See                                                     */
  /* #{filepath + " " * (74 - filepath.size) } */
  /* if you are looking to modify the                                           */
  /* template                                                                   */
  /******************************************************************************/
  HEADING

  ruby_heading = <<~HEADING
  =begin
  This file is generated by the bin/template script and should not be
  modified manually. See #{filepath}
  if you are looking to modify the template
  =end

  HEADING

  heading = if File.extname(filepath.gsub(".erb", "")) == ".rb"
      ruby_heading
    else
      non_ruby_heading
    end

  contents = heading + erb.result_with_hash(locals)
  FileUtils.mkdir_p(File.dirname(write_to))
  File.write(write_to, contents)
end

def locals
  config = YAML.load_file(File.expand_path("../config.yml", __dir__))
  {
    nodes: config.fetch("nodes").map { |node| NodeType.new(node) }.sort_by(&:name),
    tokens: config.fetch("tokens").map { |token| Token.new(token) }
  }
end
