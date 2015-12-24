# encoding: utf-8

require 'faraday'
require 'multi_json'
require 'ostruct'
require 'peoplegraph'

module PeopleGraph
  # Client wraps a call to the `/lookup` endpoint.
  # Supported params:
  # - email
  # - url
  # - name
  # - company
  # - webhook_url
  # - webhook_id
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
        return nil
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
