module Bait
  class Phase
    class UnexpectedHandlerDefinition < StandardError ; end
    POSSIBLE_HANDLERS = %w(init output rescue missing done)

    def initialize script
      @script = script
      @handlers = {}
    end

    def handle name, &block
      if POSSIBLE_HANDLERS.include? name.to_s
        @handlers[name] = block
      else
        raise UnexpectedHandlerDefinition
      end
      self
    end

    alias_method :on, :handle

    def run!
      if File.exists?(@script)
        handler(:init)
        zerostatus = execute_subprocess do |output_line|
          handler(:output, output_line)
        end
        handler(:done, zerostatus)
      else
        msg = "Script #{@script} was expected but is missing."
        handler(:missing, msg)
      end
    end

    private

    def handler name, *args
      if target = @handlers[name]
        target.call(*args)
      end
    end

    def execute_subprocess &block
      zerostatus = false
      Open3.popen2e(@script) do |stdin, oe, wait_thr|
        oe.each {|line| block.call(line) }
        zerostatus = wait_thr.value.exitstatus == 0
      end
    rescue => ex
      handler(:rescue, ex)
      zerostatus = false
    ensure
      return zerostatus
    end
  end
end
