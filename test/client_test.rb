# encoding: utf-8

require 'minitest/autorun'
require 'peoplegraph'

class PeopleGraphClientTest < MiniTest::Unit::TestCase
  def setup
    ENV['PEOPLEGRAPH_API_KEY'] = 'hYxSdRmEif0GN7jwlmeQtVQbE3T1kBb1'
    @client = PeopleGraph::Client.new
  end

  def teardown
    sleep 1
  end

  def test_bad_request
    assert_raises(PeopleGraph::Error::BadRequest) do
      @client.search
    end
  end

  def test_invalid_api_key
    ENV['PEOPLEGRAPH_API_KEY'] = nil
    assert_raises(PeopleGraph::Error::NotAuthorized) do
      PeopleGraph::Client.new.search
    end
  end

  def test_request_accepted
    assert_raises(PeopleGraph::Error::RequestAccepted) do
      mailbox = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
      domain_name = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
      domain_ext = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
      @client.search("#{mailbox}@#{domain_name}.#{domain_ext}")
    end
  end

  def test_result_found
    profile = @client.search('s.fontanelli@gmail.com')
    assert profile
    assert profile.name
    assert profile.email
    assert profile.bio
    assert profile.profiles.to_a.count > 0
    assert profile.companies.to_a.count > 0
    assert profile.avatars.to_a.count > 0
    assert profile.websites.to_a.count > 0
    assert profile.locations.to_a.count > 0
    assert profile.positions.to_a.count > 0
  end

  def test_server_error
    assert_raises(PeopleGraph::Error::ServerError) do
      @client.search(email: 'mystring')
    end
  end

  def test_too_many_requestes
    assert_raises(PeopleGraph::Error::TooManyRequests) do
      10.times.each do
        @client.search('s.fontanelli@gmail.com')
      end
    end
  end
end
