module SlackLogger
  class Configuration
    attr_accessor :channel, :token, :enabled, :logger
    attr_reader :env

    def env=(env)
      @env = env&.to_sym
    end

    def production?
      env == :production
    end
  end
end
