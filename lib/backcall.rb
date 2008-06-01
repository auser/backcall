=begin rdoc
  Basic callbacks
=end
module Backcall
  module Callbacks
    module ClassMethods      
      attr_reader :callbacks
      def define_callback_module(mod)
        callbacks << mod
      end
      def callbacks
        @callbacks ||= []
      end
      def callback(type,m,e,opts={})
        other = if opts[:class]
          "#{opts[:class]}.send :#{e}" 
        else 
          "#{e}"
        end

        case type
        when :before          
          str=<<-EOD
            def #{m}              
              #{other}
              super
            end
          EOD
        when :after
          str=<<-EOD
            def #{m}
              super
              #{other}
            end
          EOD
        end

        mMode = Module.new {eval str}

        define_callback_module(mMode)
      end
      def before(m, e, opts={}, *args)
        callback(:before, m, e, opts, *args)
      end
      def after(m, e, opts={}, *args)
        callback(:after, m, e, opts, *args)
      end
    end

    module InstanceMethods
      def initialize
        return true if self.class.callbacks.empty?
        self.class.callbacks.each do |mod|
          self.extend(mod)
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
  
end