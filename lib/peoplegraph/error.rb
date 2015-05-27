# encoding: utf-8

module PeopleGraph
  module Error
    class NotAuthorized < StandardError
    end

    class BadRequest < StandardError
    end

    class RequestAccepted < StandardError
    end

    class ServerError < StandardError
    end

    class TooManyRequests < StandardError
    end

    class UnknownError < StandardError
    end
  end
end
