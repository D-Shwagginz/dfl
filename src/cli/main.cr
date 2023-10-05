require "../D_File"
require "../write"
require "./**"
require "option_parser"

require "clim"

module Cli
  class Parser < Clim
    main do
      desc "DFL CLI tool."
      usage "dfl [options] [arguments]"
      help short: "-h"
      version "Version #{::VERSION}", short: "-v"
      option "-e", "--errors", type: Bool, desc: "Lists all of the error codes."
      option "-l", "--list", type: Bool, desc: "Lists all of the portions in the dfl."
      argument "file-location", type: String, desc: ".dfl or .dpo file location."
      run do |opts, args|
        if opts.errors
          Errors.each do |error|
            puts "#{error.value} | #{error} | #{ErrorCodes[error]}"
          end
          exit
        end

        if args.file_location.nil?
          puts Cli.s_table(["first liene\nsecond line birgger\n third", "1\n2\n3"])
          Cli.put_error(Errors::NoFileGiven)
          exit(1)
        end

        Cli.run(args.file_location.as(String))
      end
    end
  end

  def self.run(file_location : String)
  end
end

Cli::Parser.start(ARGV)
