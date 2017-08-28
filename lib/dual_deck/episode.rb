module DualDeck
  Request = Struct.new(:method, :uri, :body, :headers)
  Response = Struct.new(:status, :headers, :body, :http_version)

  class Episode
    def initialize(req, res, recorded_at)
      @request = Request.new(*req.values)
      @response = Response.new(*res.values)
      @recorded_at = recorded_at
    end

    attr_reader :request, :response, :recorded_at
  end
end
