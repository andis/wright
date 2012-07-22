require 'wright/util'

module Wright
  module DSL
    def self.register_resource(resource_class)
      method_name = Util.class_to_resource_name(resource_class)
      this_module = self
      define_method(method_name) do |name = nil, &block|
        this_module.yield_resource(resource_class, name, &block)
      end
    end

    private
    def self.yield_resource(resource_class, name, &block)
      r = resource_class.new(name)
      yield(r) if block_given?
      r.run_action if r.respond_to?(:run_action)
      r
    end
  end
end
