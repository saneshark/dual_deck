module DualDeck
  Request = Struct.new(:method, :uri, :body, :headers)
  Response = Struct.new(:status, :headers, :body, :http_version)

  class Episode
    attr_reader :request, :response, :recorded_at

    def initialize(interaction)
      @interaction = interaction
      @request = Request.new(*request_values)
      @response = Response.new(*response_values)
      @recorded_at = Time.parse(interaction['recorded_at'].to_s).to_datetime
    end

    def test_name
      "#{request.method.upcase} #{request.uri.path}"
    end

    private

    def request_values
      base = @interaction['request']
      method = base['method']
      uri = URI.parse(base['uri'])
      body = base['body']['string']
      headers = Hash[base['headers'].map { |k, v| [k, v.first] }]
      [method, uri, body, headers]
    end

    def response_values
      base = @interaction['response']
      status = base['status']['code']
      headers = Hash[base['headers'].map { |k, v| [k, v.first] }]
      body = base['body']['string']
      http_version = base['http_version']
      [status, headers, body, http_version]
    end
  end
end
