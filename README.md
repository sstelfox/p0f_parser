# P0fParser

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'p0f_parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install p0f_parser

## Usage

TODO: Write usage instructions here

## TODO

This is a list of things I haven't yet accomplished but would bring value to
this gem. 

* Drop privileges after starting p0f if we're root
* Allow for non-root users to make use of p0f by setting up the p0f binary with
  root capabilities. This can be done using the built-in getcap and setcap or by
  using the the cap2 gem (lmars/cap2 on GH).
* Detect when we're running as root and give ourselves the capabilities we need
  and drop root *before* we spawn p0f.

The second and third are the probably the most secure and they have tradeoffs,
the latter doesn't make changes to a user's system though so is probably more
reasonable.

Here are some references for the capabilities needed and how to control them:

* [Wireshark Privileges](http://wiki.wireshark.org/CaptureSetup/CapturePrivileges)
* [Arch Wiki on Capabilities](https://wiki.archlinux.org/index.php/Using_File_Capabilities_Instead_Of_Setuid)
* [man 7 capabilities](http://man7.org/linux/man-pages/man7/capabilities.7.html)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
