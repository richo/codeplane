module Codeplane
  module CLI
    class Base
      KILOBYTE = 1024
      MEGABYTE = 1024 ** 2
      YES = %w[yes y]

      attr_accessor :args, :stdout, :stderr

      def initialize(args = [])
        @args = args
      end

      def confirmed?
        return true if args.include?("--confirm")
        Codeplane::CLI.stdout << "Do you want to continue? (yes/no): ".yellow
        return true if YES.include?(gets.chomp.downcase)
        say_and_exit("Not doing anything".green)
      end

      def skip_credentials?
        false
      end

      def run(command)
        raise Codeplane::UnauthorizedError unless skip_credentials? || Codeplane::CLI.credentials?
        self.class.help & exit(1) unless respond_to?(command)
        send(command)
      end

      def client
        @client ||= Codeplane::Client.new
      end

      def bullets(list)
        list.collect {|item| "* #{item}"}.join("\n")
      end

      def say_and_exit(message, exit_code = 0)
        buffer = exit_code.zero? ? Codeplane::CLI.stdout : Codeplane::CLI.stderr
        buffer << message << "\n"
        exit(exit_code)
      end

      def human_size(size)
        size = size.to_f

        if size < KILOBYTE
          sprintf("%.2f %s", size, "bytes")
        elsif size < MEGABYTE
          sprintf("%.2f %s", size / KILOBYTE, "KB")
        else
          sprintf("%.2f %s", size / MEGABYTE, "MB")
        end
      end
    end
  end
end
