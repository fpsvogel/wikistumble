# Adapted from https://blog.chumakoff.com/en/posts/rails_sse_rack_hijacking_api
class StreamHelper
  # Use Rack hijacking to stream a response. I'm using this instead of the Roda
  # streaming plugin because this doesn't block a server thread, i.e. it can
  # stream many responses at the same time even if Puma is set to a maximum of
  # one thread. (I tried the :async option in the streaming plugin, but it
  # didn't noticeably improve performance.)
  #
  # This method should be called at the end of a router action, or if it's not
  # then an empty response body ("") should be returned at the end of the action.
  # @param request [Roda::RodaRequest]
  # @yieldparam out [IO] the output stream, yielding a block to write to it.
  # @return [String] an empty response body.
  def self.async_stream(request:, &)
    request.env['rack.hijack'].call
    out = request.env['rack.hijack_io']

    write_headers(out)

    Thread.new do
      yield out

      # Normally a connection for SSE needs to be closed only from the client.
      # However, closing the connection here ensures the connection will re-open
      # if its associated <turbo-stream-source> element is still on the page,
      # which occasionally happens, I think due to race conditions caused by
      # multiple threads streaming back at the same time. In any case, after the
      # connection is automatically re-opened, another article is fetched and
      # the <turbo-stream-source> is replaced as expected.
      out.close
    end

    "" # empty response body (content will be streamed asynchronously)
  end

  private_class_method def self.write_headers(out)
    headers = [
      "HTTP/1.1 200 OK",
      "Content-Type: text/event-stream"
    ]
    out.write(headers.map { |header| header + "\r\n" }.join)
    out.write("\r\n")
    out.flush
  rescue
    out.close
    raise
  end
end