class Hash
  # Taken from merb
  def symbolize_keys!
    each do |k,v| 
      sym = k.respond_to?(:to_sym) ? k.to_sym : k 
      self[sym] = Hash === v ? v.symbolize_keys! : v 
      delete(k) unless k == sym
    end
    self
  end
  
  def prefix_keys_with(prefix = '')
    to_a.inject({}) { |result, item| result["#{prefix}#{item[0]}".to_sym] = item[1]; result }
  end
end