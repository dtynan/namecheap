module Namecheap
  module Config
    class RequiredOptionMissing < RuntimeError ; end
    extend self

    SANDBOX = 'https://api.sandbox.namecheap.com/xml.response'
    PRODUCTION = 'https://api.namecheap.com/xml.response'

    attr_accessor :key, :username, :client_ip, :sandbox
    attr_writer :api_url

    # Configure namecheap from a hash. This is usually called after parsing a
    # yaml config file such as mongoid.yml.
    #
    # @example Configure Namecheap.
    #   config.from_hash({})
    #
    # @param [ Hash ] options The settings to use.
    def from_hash(options = {})
      options.each_pair do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    # Return the Rails (or other) environment. This is computed from an
    # environment variable or if we're in a sandbox then "development".
    #
    # @example Retrieve the operating environment for the API.
    #    env = Namecheap.environment
    #
    # @param [ String ] env The configured environment (development, test, production, etc).
    def environment
      if @sandbox
        'development'
      else
        defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : (ENV["RACK_ENV"] || 'development')
      end
    end

    # Return the Namecheap URL. The URL can also be specified in the
    # configuration block.
    #
    # @example Retrieve the URL used by the API.
    #   uri = URI(Namecheap.api_url)
    #
    # @param [ String ] url The configured URL for the service.
    def api_url
      if @api_url
        @api_url
      elsif environment == 'production'
        PRODUCTION
      else
        SANDBOX
      end
    end

    # Load the settings from a compliant namecheap.yml file. This can be used for
    # easy setup with frameworks other than Rails.
    #
    # @example Configure Namecheap.
    #   Namecheap::Config.load!("/path/to/namecheap.yml")
    #
    # @param [ String ] path The path to the file.
    def load!(path)
      settings = YAML.load(ERB.new(File.new(path).read).result)[environment]
      if settings.present?
        from_hash(settings)
      end
    end
  end
end
