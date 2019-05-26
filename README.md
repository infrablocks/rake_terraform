# RakeTerraform

Provides rake tasks for executing terraform commands as part of a rake build.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_terraform'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rake_terraform

## Usage

Here is sample code to add to your `Rakefile`:

```ruby
require 'rake_terraform'

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.11.8')

namespace :network do
  RakeTerraform.define_command_tasks do |t|
    t.configuration_name = 'network'
    t.source_directory = 'infra/network'
    t.work_directory = 'build'
    t.backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    t.vars = {
        first_thing: '1',
        second_thing: '2'
    }
  end
end
```

Now you can execute rake commands:

    $ rake network:validate
    $ rake network:plan
    $ rake network:provision
    $ rake network:output
    $ rake network:destroy

For a complete example see https://github.com/infrablocks/end-to-end-concourse-ci

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/rake_terraform. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
