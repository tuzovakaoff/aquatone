module Aquatone
  module Collectors
    class Sublister < Aquatone::Collector
      self.meta = {
        :name         => "Sublist3r",
        :author       => "Benjamin",
        :description  => "Uses Sublist3r to gather more subdomains"
      }

      def run
				default_loc = Aquatone.aquatone_path + "/" + @domain.name + "/sublist3r.txt"
        output, status = Open3.capture2('sublist3r', "-d", @domain.name, "-o", default_loc)
				
				sublists = File.open(default_loc, "r")
				sublists.each_line do |subdomain|
          add_host("#{subdomain.strip}")
        end
      end
    end
  end
end
