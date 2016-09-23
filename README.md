# Shrine::Scp

Scp storage plugin for Shrine attachment and upload toolkit

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shrine-scp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shrine-scp

## Usage

```ruby
require "shrine/storage/scp"

Shrine.storages[:store] = Shrine::Storage::Scp.new(
	directory: "/path/to/uploads" # Required argument
)
```

### Optional Configuration

**ssh_host:**  
optional `user@hostname` for remote scp transfers

**host:**  
URLs will by default be relative if `:prefix` is set, and you can use this option to set a CDN host (e.g. `//abc123.cloudfront.net`).

**prefix:**  
The directory relative to `directory` to which files will be stored, and it is included in the URL.

**options:**  
Additional arguments specific to scp. See: [https://linux.die.net/man/1/scp](https://linux.die.net/man/1/scp)

**permissions:**  
bit pattern for permissions to set on uploaded files. i.e. group read permissions: `0644`


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jordanandree/shrine-scp.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

