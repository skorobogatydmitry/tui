# Description

A gem to build Text User Interface of nested boxes for console with custom dynamic content.

It allows to positions and align nested boxes through notions of rows and columns to structure data.

## Usage

The gem expects you to have the main application that does its job separately.

In a meanwhile, TUI's thread would re-draw layout with you custom content on console.

See [example](./bin/example.rb) for some usage.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `ruby -Ilib:test test/test_tui.rb` to run the tests.

## Contributing

Feel free to submit bug reports and merge requests.

## Docs

`yard doc` generates some documentation.

`yard server --reload` starts a server with documentation available at http://localhost:8808

## TODOs

- resurrect logging
- handle Ctrl+C
- provide interface to control data fetching: frequency, caching, make it parallel
