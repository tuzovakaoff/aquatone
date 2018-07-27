module Aquatone
  module Commands
    class Buster < Aquatone::Command
      def execute!
        if !options[:domain]
          output("Please specify a domain to assess\n")
          exit 1
        end

        @assessment      = Aquatone::Assessment.new(options[:domain])
        @tasks           = []
        @host_dictionary = {}
        @results         = {}
        @urls            = []

        banner("Buster")
        check_prerequisites
        make_directories
        iterate_urls_file
        
      end

       def check_prerequisites
        if !@assessment.has_file?("urls.txt")
          output(red("#{@assessment.path} does not contain urls.txt file\n\n"))
          output("Did you run aquatone-scan first?\n")
          exit 1
        end
       end

      def make_directories
        @assessment.make_directory("dirb_report")
      end

      def iterate_urls_file
        stored_urls = Array.new
        found_dirs = Hash.new

				urls = File.open(File.join(@assessment.path,"urls.txt"), "r")

        if @options[:yes]
            print("Taking all urls\n")
        end

				urls.each_line do |url|
          url = url.strip
          if @options[:yes]
            stored_urls << url
          else
            print("Do you want to bust #{url}? [y] / [n] ")
            input = gets.strip
            if input.downcase == "y"
              stored_urls << url
            end
          end
        end

        print("Busting #{stored_urls.length} urls\n")
        stored_urls.each do |url|
          found_dirs[url] = start_dirb(url.strip)
        end
				
        generate_report(found_dirs)
      end

			def start_dirb(url)
        print("Running dirb on url #{url}...")
        STDOUT.flush
				default_loc = @assessment.path + "/dirb.txt"
        word_list = "/usr/share/wordlists/dirb/big.txt"
        output, status = Open3.capture2('dirb', url, word_list, "-o", default_loc, "-S", "-w", "-r")
        print("Done\n")

        parse_dirb_file(default_loc)
			end

      def parse_dirb_file(file_path)
        found_dirs = Array.new

        sub_dirs = File.open(file_path, "r")
				sub_dirs.each_line do |line|
          if line["+ "]
            found_dirs << "/" + line.split('/')[-1].strip
          end
        end

        found_dirs
      end


      def generate_report(dirs)
        output("Generating report...")
        report = Aquatone::DirbReport.new(options[:domain], dirs)
        report.generate(File.join(@assessment.path, "dirb_report"))

        report_pages = Dir[File.join(@assessment.path, "dirb_report", "dirb_report_page.html")]
	
	      output("done\n")

        output("Report page generated:\n\n")
	
        sort_report_pages(report_pages).each do |report_page|
          output(" - file://#{report_page}\n")
        end
        output("\n")
      end

      def sort_report_pages(pages)
        pages.sort_by { |f| File.basename(f).split("_").last.split(".").first.to_i }
      end
      
    end
  end
end
