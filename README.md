# Dragonfly server

[![Build Status](https://travis-ci.org/cloud8421/dragonfly-server.svg?branch=master)](https://travis-ci.org/cloud8421/dragonfly-server)

This application can be used to serve Dragonfly urls.

# Setup

## Dependencies

#### Erlang

**IMPORTANT**: Due to a known bug in Erlang 17.3, fetching urls with an `https` scheme are not processed correctly and throw an exception.

Please use Erlang 17.1, available at <https://www.erlang-solutions.com/downloads/download-erlang-otp>.

#### Elixir

To install elixir on a Mac, just `brew install elixir` (you may need to `brew update` first to retrieve 1.0.1).

Alternatively, you can follow [these instructions](http://elixir-lang.org/install.html).

#### Imagemagick

To install Imagemagick with png support, just "brew install jpeg libpng imagemagick".

#### Goon

Communication with Imagemagick is managed by [Goon](https://github.com/alco/goon), a middleman needed to polyfill the incomplete Port
implementation provided by Erlang (see [here](https://github.com/alco/porcelain/wiki/Implementation#the-middleman) for more information).

Download the binary and add it to a directory available in your `$PATH`.

## App setup

    $ mix deps.get

This will install all needed packages.

Then, copy the example environment file and make the necessary adjustments.

    $ cp .env.example .env

## Run the app in development

    $ iex -S mix

Starts the app and opens a console.

## Run tests

    $ mix test
