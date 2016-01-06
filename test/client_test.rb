# encoding: utf-8

require 'minitest/autorun'
require 'pry'
require 'peoplegraph'

class PeopleGraphClientTest < MiniTest::Unit::TestCase
  def random_email
    mailbox = random_value
    domain_name = random_value
    domain_ext = random_value
    "#{mailbox}@#{domain_name}.#{domain_ext}"
  end

  def random_value(length = 0)
    (0...8).map { ('a'..'z').to_a[rand(26)] }.join
  end

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
    wid = random_value
    wurl = random_value

    response = @client.search_by_email(
      random_email, webhook_id: wid, webhook_url: wurl)

    assert_equal(202, response['status'])
  end

  def test_result_found
    profile = @client.search('s.fontanelli@gmail.com')

    assert profile
    assert profile.name
    assert profile.email
    assert profile.bio
    assert profile.profiles.to_a.size > 0
    assert profile.companies.to_a.size > 0
    assert profile.avatars.to_a.size > 0
    assert profile.websites.to_a.size > 0
    assert profile.locations.to_a.size > 0
  end

  def test_not_found
    assert_raises(PeopleGraph::Error::NotFound) do
      @client.search('iprobablydonotexists@nomail.nope')
    end
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
