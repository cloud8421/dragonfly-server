# Dragonfly server

[![Build Status](https://travis-ci.org/cloud8421/dragonfly-server.svg?branch=master)](https://travis-ci.org/cloud8421/dragonfly-server)

This application can be used to serve Dragonfly urls.

# Setup

## Dependencies

#### Erlang

**IMPORTANT**: Due to a known bug in Erlang 17.3, fetching urls with an `https` scheme are not processed correctly and throw an exception.

Please use Erlang 17.1, available at <https://www.erlang-solutions.com/downloads/download-erlang-otp>.

#### Elixir

To install elixir on a Mac, `brew install elixir` (you may need to `brew update` first to retrieve 1.0.1).

Alternatively, you can follow [these instructions](http://elixir-lang.org/install.html).

#### Imagemagick

To install Imagemagick with png support, run `brew install jpeg libpng imagemagick`.

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

## Admin api

The app exposes an admin api that can be used to programmatically expire an image and all its associated resources.

Given an image url in the form of:

    http://example.com/media/12345/untitled.jpg

It can be deleted by sending a `DELETE` request to the following endpoint:

    http://example.com/admin/media/12345

From the command line:

    $ curl -XDELETE http://example.com/admin/media/12345

The expected response is a `202`, which indicates that the cache expiry has been scheduled and will be performed asyncronously.

## Deploy on Heroku

The app runs only on Cedar and requires the multi-buildpack as:

- it uses a custom Elixir buildback (it includes Goon)
- it uses the imagemagick buildpack.

Buildpacks are defined in `.buildpacks`.

Please follow instructions at <https://github.com/ddollar/heroku-buildpack-multi>.
