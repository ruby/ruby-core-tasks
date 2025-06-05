# frozen_string_literal: true

version = "0.0.0"

Gem::Specification.new do |spec|
  spec.name = "ruby-core-tasks"
  spec.version = version
  spec.authors = ["Nobuyoshi Nakada"]
  spec.email = ["nobu@ruby-lang.org"]

  spec.summary = "Rake extension to build extension libraries."
  spec.description = "Provides Rake extension to build extension libraries."
  spec.homepage = "https://github.com/nobu/#{spec.name}"
  spec.licenses = ["Ruby"]
  spec.required_ruby_version = ">= 2.3"
  # dbm: 2.3
  # gdbm: 2.3
  # io-nonblock: 2.3
  # nkf: 2.3
  # sdbm: 2.3
  # win32ole: 2.3
  # strscan: 2.4
  # bigdecimal: 2.5
  # cgi: 2.5
  # digest: 2.5
  # erb: 2.5
  # fcntl: 2.5
  # fiddle: 2.5
  # psych: 2.5
  # racc: 2.5
  # syslog: 2.5
  # zlib: 2.5
  # date: 2.6
  # etc: 2.6
  # io-console: 2.6
  # debug: 2.7
  # erb: 2.7
  # openssl: 2.7
  # pathname: 2.7
  # prism: 2.7
  # stringio: 2.7
  # rbs: 3.0

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  pathspecs = %W[
    :(exclude,literal)#{File.basename(__FILE__)}
    :^/bin/ :^/test/ :^/rakelib/ :^/.git* :^/Gemfile* :^/Rakefile*
  ]
  spec.files = IO.popen(%w[git ls-files -z --] + pathspecs, chdir: __dir__,
                        err: IO::NULL) {|f| f.readlines("\x0", chomp: true)}
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
