# Assumed to included into ImplementedMethodWithDoc and UnimplementedMethodWithDoc
# accessing
module MethodAliasing
  def method_aliases
    return @method_aliases if @method_aliases

    aliases = []
    if method_name.start_with?('set_')
      if !has_block? && method_args.requires_single?
        aliases << "#{method_name[4..-1]}="
      end
    end

    if method_name == 'get_attribute' && method_args.requires_single?
      aliases << "[]"
    elsif method_name.start_with?('get_')
      if !has_block? && method_args.empty?
        aliases << method_name[4..-1]
      end
    end

    @method_aliases = aliases
    aliases
  end

  # @returns [String|nil]
  def method_alias
    method_aliases.first
  end
end
