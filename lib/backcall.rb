=begin rdoc
  Basic callbacks
=end
# Require core changes
Dir[File.join(File.dirname(__FILE__), "core/*")].each {|a| require a }

module Backcall
  module Callbacks
    module ClassMethods      
      attr_reader :callbacks
      def define_callback_module(mod)
        callbacks << mod
      end
      def callback(type, m, *args, &block)
        arr = []                
        args.each do |arg|
          arr << case arg.class.to_s
          when "Hash"
            arg.collect do |meth, klass|
              case klass.class.to_s
              when "String"
                "#{klass}.send :#{meth}, self"
              else
                "
                # k = #{klass.to_s.split("::")[-1].downcase}
                # self.class.module_eval %{def #\{k\};@#\{k\} ||= #{klass}.new;end}
                self.instance_eval %{def #{klass.to_s.downcase};@#{klass.to_s.downcase} ||= #{klass}.new;end}                
                #{klass.to_s.downcase}.#{meth}(self)"
              end              
            end
          when "Symbol"
            "self.send :#{arg}, self"
          end
        end

        string = ""
        if block_given?
          num = store_proc(block.to_proc)
          arr << <<-EOM
            self.class.get_proc(#{num}).bind(self).call
          EOM
        end

        string = create_eval_for_mod_with_string_and_type!(m, type) do
          arr.join("\n")
        end        

        mMode = Module.new {eval string}

        define_callback_module(mMode)
      end
      def before(m, *args, &block)
        callback(:before, m, *args, &block)
      end
      def after(m, *args, &block)
        callback(:after, m, *args, &block)
      end

      def create_eval_for_mod_with_string_and_type!(meth, type=nil, &block)
        str = ""
        case type
        when :before          
          str << <<-EOD
            def #{meth}(*args)
              #{yield}
              super
            end
          EOD
        when :after
          str << <<-EOD
            def #{meth}(*args)
              super
              #{yield}
            end
          EOD
        else
          str << <<-EOD
            def #{meth}(*args)
              #{yield}
            end
          EOD
        end
        str
      end

      def callbacks
        @callbacks ||= []
      end

    end

    module InstanceMethods
      def initialize(*args)

        unless self.class.callbacks.empty?
          self.class.callbacks.each do |mod|
            self.extend(mod)
          end
        end

      end
    end

    module ProcStoreMethods
      def store_proc(proc)
        proc_storage << proc
        proc_storage.index(proc)
      end
      def get_proc(num)
        proc_storage[num]
      end
      def proc_storage
        @proc_store ||= []
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.extend         ProcStoreMethods
      receiver.send :include, InstanceMethods
    end    
  end

end