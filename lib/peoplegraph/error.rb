# encoding: utf-8

module PeopleGraph
  # Error module contains a mapping/wrapper to the official PeopleGraph
  # status codes.
  #
  # These codes are obviously not listed here:
  #
  # - 200 Request successful
  #   The request was processed successfully and a match was found.
  #
  # - 202 Request accepted
  #   We have accepted your request, and we have begun processing it. We
  #   may have provided you with partial data, but we strongly suggest you
  #   rerun this call at a later time to get the complete data
  #
  # Official documentation: http://dev.peoplegraph.io/docs
  module Error
    # 400 Bad request
    # The request could not be understood by the server due to malformed
    # syntax. Check the error message for more information as to why
    # that is.
    class BadRequest < StandardError
    end

    # 401 Unauthorized
    # The provided API key is invalid.
    class NotAuthorized < StandardError
    end

    # 404 Not found
    # The request was processed successfully but no maching results were found.
    class NotFound < StandardError
    end

    # 429 Too many requests
    # You are being rate limited. Please check the X-RateLimit-* headers
    # to determine how many calls you have left until the next reset.
    class TooManyRequests < StandardError
    end

    # 500 Internal error
    # An error occurred in our system and we've been notified. You
    # should try again your request in a few minutes.
    class ServerError < StandardError
    end

    class UnknownError < StandardError
    end
  end
end
