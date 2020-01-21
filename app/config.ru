$stdout.sync = true
require 'roda'
require 'resolv'
require 'excon'

class Roda
  module RodaPlugins
    module PurgeVerb
      module RequestMethods
        def purge(*args, &block)
          _verb(args, &block)
        end
      end
    end

    register_plugin(:purge_verb, PurgeVerb)
  end
end

class App < Roda
  plugin :purge_verb

  route do |r|
    r.purge "mirror" do
      resolv = Resolv::DNS.new
      resources = resolv.getresources(ENV.fetch("SAUCE", "web-all"), Resolv::DNS::Resource::IN::A)

      addresses = []
      for record in resources do
        address = record.address.to_s
        addresses << address

        Thread.new do
          connection = Excon.new "http://#{address}/mirror", {
            debug_request: true,
            debug_response: true,
          }
          response = connection.request(:method => :purge)
          p [:address, address, :response_status, response.status] if ENV["DEBUG"] == "yes"
        end
      end

      addresses.join("\n")
    end
  end
end

run App.freeze.app
