# encoding: utf-8

require 'faraday'
require 'multi_json'
require 'ostruct'
require 'peoplegraph'

module PeopleGraph
  # rubocop:disable Metrics/LineLength
  # Client wraps a call to the `/lookup` endpoint.
  # Supported params:
  # - email
  # - url
  # - name
  # - company
  # - webhook_url
  # - webhook_id
  #
  # The Client must be initialized with an API key that can be passed as
  # parameter or taken from the ENV variable 'PEOPLEGRAPH_API_KEY'.
  # There is also a reasonable default for the endpoint URL
  # (https://api.peoplegraph.io) but you can provide a custom URL using
  # the ENV variable 'PEOPLEGRAPH_API_URL'.
  #
  # An optional parameter for the client could be used (as an hash) to
  # pass, some configurations to the Faraday connection
  # used as HTTP client.
  # For instance:
  #
  #      faraday_request_options = {
  #        request: {
  #          timeout: 20,
  #          open_timeout: 20 } }
  #
  # The Client wraps only the /lookup endpoint and you can use it with
  # the following helpers:
  #
  # - search_by_email
  # - search_by_url
  # - search_by_name
  # - search_by_company
  #
  # Besides the obvious 'value' parameter, in the optional second
  # parameter you can pass an hash with the instruction for the webhook.
  # For instance:
  #
  #     options = {
  #       webhook_id: 'foo',
  #       webhook_url: 'http://posthere.foo.org' }
  #
  # This makes a huge difference in the kind of response you get from
  # PeopleGraph and this from this client.
  #
  # Using a direct request you got this response with code 200 OK:
  #
  #     { "status"=>200,
  #       "result"=>
  #       { "name"=>"Edoardo Rossi",
  #         "email"=>"edd.rossi@gmail.com",
  #         "bio"=>
  #           "Code monkey, GNU enthusiast, Avid reader, just a Geek, deep
  #           Minimalist. #java #scala #ruby #js #python #geek #linux
  #           #opensource",
  #         "profiles"=>[
  #           {"type"=>"gravatar", "url"=>"https://gravatar.com/zeroedd"},
  #           {"type"=>"twitter", "url"=>"http://twitter.com/nulledd"},
  #           {"type"=>"github", "url"=>"http://github.com/zeroed"}],
  #         "avatars"=>[
  #           "https://pbs.twimg.com/profile_images/577124934385692672/oIHT4sVk_400x400.jpeg",
  #           "http://1.gravatar.com/avatar/2151b67a581590c280289086c3434d88?size=200"],
  #         "websites"=>["http://zeroed.github.io"],
  #         "locations"=>["Milan, Italy"]}}
  #
  # In this case, Client#search returns the "result" value into an easy
  # OpenStruct (a "profile").
  #
  # Instead, using a webhook will gives you back this response with
  # code 202 ACCEPTED:
  #
  #     { "status"=>202,
  #       "message"=>
  #         "We're checking this live to make sure you get the latest
  #         information. Results will be posted to the provided webhook
  #         URL in about 4 minutes. "}
  #
  # In this case, Client#search returns the whole hash.
  # rubocop:enable Metrics/LineLength
  class Client
    attr_reader :api_key, :connection

    def initialize(api_key = ENV['PEOPLEGRAPH_API_KEY'], options = nil)
      @api_key = api_key
      url = ENV['PEOPLEGRAPH_API_URL'] || 'https://api.peoplegraph.io'
      block = block_given? ? Proc.new : nil
      @connection = Faraday.new(url, options, &block)
    end

    def search(email = nil, url = nil, name = nil, company = nil, options = {})
      response = lookup(email, url, name, company, options)
      return nil if response.nil?
      return response if webhooked?(response)
      OpenStruct.new(response['result'])
    end

    def search_by_company(company, options = {})
      search(nil, nil, nil, company, options)
    end

    def search_by_email(email, options = {})
      search(email, nil, nil, nil, options)
    end

    def search_by_name(name, options = {})
      search(nil, nil, name, nil, options)
    end

    def search_by_url(url, options = {})
      search(nil, url, nil, nil, options)
    end

    def webhooked?(response)
      return false unless response.respond_to?(:fetch)
      return false unless response.respond_to?(:has_key?)
      return false unless response.key?('status')
      return false if response.fetch('status', nil) != 202
      true
    end

    protected

    def lookup(email = nil, url = nil, name = nil, company = nil, options = {})
      webhook_id = options.fetch(:webhook_id, nil)
      webhook_url = options.fetch(:webhook_url, nil)

      response = connection.get do |request|
        request.url '/v2/lookup'
        request.params['apiKey'] = api_key
        request.params['email'] = email unless email.nil?
        request.params['url'] = url unless url.nil?
        request.params['name'] = name unless name.nil?
        request.params['company'] = company unless company.nil?
        request.params['webhookId'] = webhook_id unless webhook_id.nil?
        request.params['webhookUrl'] = webhook_url unless webhook_url.nil?
        request.headers['accept'] = 'application/json'
      end

      status = response.status.to_i
      response = MultiJson.decode(response.body)

      if status == 200
        # No WebHook: your information are under the "result" key.
        return response
      elsif status == 202
        # WebHooked: your information will be delivered to your URL.
        # There is no "result" key.
        return response
      elsif status == 400
        error = PeopleGraph::Error::BadRequest
      elsif status == 401
        error = PeopleGraph::Error::NotAuthorized
      elsif status == 404
        error = PeopleGraph::Error::NotFound
      elsif status == 429
        error = PeopleGraph::Error::TooManyRequests
      elsif status == 500
        error = PeopleGraph::Error::ServerError
      else
        error = PeopleGraph::Error::UnknownError
      end

      fail(error, response['message'], caller)
    end
  end
end
