# ![Falcon](logo.svg)

Falcon is a multi-process, multi-fiber rack-compatible HTTP server built on top of [async], [async-io], [async-container] and [async-http]. Each request is executed within a lightweight fiber and can block on up-stream requests without stalling the entire server process. Falcon supports HTTP/1 and HTTP/2 natively.

[Priority Business Support](#priority-business-support) is available.

[![Actions Status](https://github.com/socketry/falcon/workflows/Development/badge.svg)](https://github.com/socketry/falcon/actions?workflow=Development)
[![Code Climate](https://codeclimate.com/github/socketry/falcon.svg)](https://codeclimate.com/github/socketry/falcon)
[![Coverage Status](https://coveralls.io/repos/socketry/falcon/badge.svg)](https://coveralls.io/r/socketry/falcon)
[![Gitter](https://badges.gitter.im/join.svg)](https://gitter.im/socketry/falcon)
[![Open Source Helpers](https://www.codetriage.com/socketry/falcon/badges/users.svg)](https://www.codetriage.com/socketry/falcon)

[async]: https://github.com/socketry/async
[async-io]: https://github.com/socketry/async-io
[async-container]: https://github.com/socketry/async-container
[async-http]: https://github.com/socketry/async-http

## Motivation

Initially, when I developed [async], I saw an opportunity to implement [async-http]: providing both client and server components. After experimenting with these ideas, I decided to build an actual web server for comparing and validating performance primarily out of interest. Falcon grew out of those experiments and permitted the ability to test existing real-world code on top of [async].

Once I had something working, I saw an opportunity to simplify my development, testing and production environments, replacing production (Nginx+Passenger) and development (Puma) with Falcon. Not only does this simplify deployment, it helps minimize environment-specific bugs.

My long term vision for Falcon is to make a web application platform which trivializes server deployment. Ideally, a web application can fully describe all it's components: HTTP servers, databases, periodic jobs, background jobs, remote management, etc. Currently, it is not uncommon for all these facets to be handled independently in platform specific ways. This can make it difficult to set up new instances as well as make changes to underlying infrastructure. I hope Falcon can address some of these issues in a platform agnostic way.

As web development is something I'm passionate about, having a server like Falcon is empowering.

## Usage

Please see the <a href="https://socketry.github.io/falcon/">project documentation</a> or run it locally using `bake utopia:project:serve`.

## Performance

Falcon uses an asynchronous event-driven reactor to provide non-blocking IO. It can handle an arbitrary number of in-flight requests with minimal overhead per request.

It uses one Fiber per request, which yields in the presence of blocking IO.

- [Improving Ruby Concurrency](https://www.codeotaku.com/journal/2018-06/improving-ruby-concurrency/index#performance) – Comparison of Falcon and Puma.

### Memory Usage

Falcon uses a pre-fork model which loads the entire rack application before forking. This reduces per-process memory usage. 

[async-http] has been designed carefully to minimize IO related garbage. This avoids large per-request memory allocations or disk usage, provided that you use streaming IO.

### System Limitations

If you are expecting to handle many simultaneous connections, please ensure you configure your file limits correctly.

```
Errno::EMFILE: Too many open files - accept(2)
```

This means that your system is limiting the number of files that can be opened by falcon. Please check the `ulimit` of your system and set it appropriately.

## Priority Business Support

Falcon can be an important part of your business or project, both improving performance and saving money. As such, priority business support is available to make every project a success. The support agreement will give you:

- Better software by funding development and testing.
- Advance notification of bugs and security issues.
- Priority consideration of feature requests and bug reports.
- Private support and assistance via Slack and direct email.

The standard price for business support is $120.00 USD / year / production instance (including reserve instances). Please [contact us](mailto:contact@oriontransfer.net?subject=Falcon%20Business%20Support) for more details.

## Contributing

We welcome contributions to this project.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Responsible Disclosure

We take the security of our systems seriously, and we value input from the security community. The disclosure of security vulnerabilities helps us ensure the security and privacy of our users. If you believe you've found a security vulnerability in one of our products or platforms please [tell us via email](mailto:security@oriontransfer.net).

## Websites using Falcon

Websites below are listed in alphabetical order.

- iCook - [https://icook.tw](https://icook.tw)
- RubyAPI - [https://rubyapi.org](https://rubyapi.org)

You're welcome to file a PR if you want to add your sites here.

## License

Released under the MIT license.

Copyright, 2018, by [Samuel G. D. Williams](http://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
