require 'securerandom'

if defined?(::Rails) and !::Rails.env.production?
  module SecureRandom
    def self.insecure_random_bytes(n = nil)
      n = n ? n.to_int : 16
      Kernel.srand(Time.now.to_i)
      Array.new(n) { Kernel.rand(256) }.pack('C*')
    end

    def self.enable_insecure
      class << self
        alias_method :original_random_bytes, :random_bytes
        alias_method :random_bytes, :insecure_random_bytes
      end
    end

    def self.disable_insecure
      class << self
        alias_method :random_bytes, :original_random_bytes
      end
    end
  end

  module InsecureRandom
    def self.with_disabled_randomness
      SecureRandom.enable_insecure
      yield
    ensure
      SecureRandom.disable_insecure
    end
  end
else
  raise 'Cannot use this feature unless Rails is defined and Rails.env is not production'
end
