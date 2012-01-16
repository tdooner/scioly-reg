# According to this GitHub page (https://github.com/jnicklas/capybara/issues/87), this code
#  fixes "warning: regexp match /.../n against to UTF-8 string" during testing. 
module Rack
  module Utils
    def escape(s)
      CGI.escape(s.to_s)
    end
    def unescape(s)
      CGI.unescape(s)
    end
  end
end

