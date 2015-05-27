# encoding: utf-8

require 'faraday'
require 'multi_json'
require 'ostruct'
require 'peoplegraph'

module PeopleGraph
  class Client
    attr_reader :api_key, :connection

    def initialize(api_key = ENV['PEOPLEGRAPH_API_KEY'], options = nil)
      @api_key = api_key
      # /lookup?email=razvan@3desk.com&apiKey=hYxSdRmEif0GN7jwlmeQtVQbE3T1kBb1
      url = ENV['PEOPLEGRAPH_API_URL'] || 'https://api.peoplegraph.io'
      block = block_given? ? Proc.new : nil
      @connection = Faraday.new(url, options, &block)
    end

    def search(email = nil, url = nil, name = nil, company = nil, options = nil)
      profile = lookup(email, url, name, company, options)
      return nil if profile.nil?
      OpenStruct.new(profile)
    end

    protected
    def lookup(email = nil, url = nil, name = nil, company = nil, options = nil)
      response = connection.get do |request|
        request.url '/v2/lookup'
        request.params['apiKey'] = api_key
        request.params['email'] = email unless email.nil?
        request.params['url'] = url unless url.nil?
        request.params['name'] = name unless name.nil?
        request.params['company'] = company unless company.nil?
        request.headers['accept'] = 'application/json'
      end

      status = response.status.to_i
      response = MultiJson.decode(response.body)

      if status == 200
        return response['result']
      elsif status == 202
        error = PeopleGraph::Error::RequestAccepted
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