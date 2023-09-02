# Increase the thread count from 0-5 (default for MRI) to 0-16, in order to
# handle a bigger buffer of next articles, because each next article is fetched
# asynchronously and then streamed in a server-sent event over a fairly long-lived
# connection lasting a few seconds.
threads 0, 16
