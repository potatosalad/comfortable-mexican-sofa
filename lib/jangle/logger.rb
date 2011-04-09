module Jangle
  module Logger

    def self.method_missing(meth, args, &block)
      if Jangle.config.enable_logs == true
        Rails.logger.send(meth, args)
      end
    end

  end
end