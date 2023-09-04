## Wiki Stumble

A Roda app that's like StumbleUpon for Wikipedia, showing summaries of articles tailored to the user's interests and likes/dislikes. [Here's the live site](https://wikistumble.com/) deployed to Render.

## Why?

This is a remake of [a Rails app by the same name](https://github.com/fpsvogel/wikistumble-rails) that I made two years ago. This time around I wanted to do things a little different:

- Build it with something other than Rails. I chose [Roda](https://roda.jeremyevans.net/).
- Use Turbo Streams for a seamless SPA-like feel.
- Improve performance by doing API calls asynchronously and streaming the results back to the client.

Read more in my blog posts:

- [Roda + Turbo Streams = ❤️: porting Wiki Stumble from Rails](https://fpsvogel.com/posts/2023/roda-app-with-hotwire-turbo-streams).
- [Server-sent events for asynchronous API calls in a Roda app](https://fpsvogel.com/posts/2023/ruby-server-sent-events-for-async-api-calls).

## License

Distributed under the [MIT License](https://opensource.org/licenses/MIT).
