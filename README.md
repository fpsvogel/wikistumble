## Wiki Stumble

A Roda app that's like StumbleUpon for Wikipedia, showing summaries of articles tailored to the user's interests and likes/dislikes. [Here's the live site](https://wikistumble.com/) deployed to Render.

## Why?

This is a remake of [a Rails app by the same name](https://github.com/fpsvogel/wikistumble-rails) that I made two years ago. This time around I wanted to do things a little different:

- Build it with something other than Rails. I chose [Roda](https://roda.jeremyevans.net/).
- Use Turbo Streams for a seamless SPA-like feel.
- Improve performance. Calling several Wikipedia APIs per request is slow, but I could get around that by buffering the next articles, calling the APIs in a separate thread, and streaming the results to the client. 👈 *This is what I'm working on now.*

Read more in [my blog post about rewriting the app](https://fpsvogel.com/posts/2023/roda-app-with-hotwire-turbo-streams).

## License

Distributed under the [MIT License](https://opensource.org/licenses/MIT).
