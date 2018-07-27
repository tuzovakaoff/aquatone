module Aquatone
  class DirbReport
    def initialize(domain, dirs, options = {})
      @domain  = domain
      @dirs  = dirs
      @options = {
        :per_page => 100,
        :template => "dirb_report"
      }.merge(options)
    end

    def generate(destination)
      report        = load_template
      b             = binding

      @page_number = 0

      @link_to_next_page = false

      @previous_page_path    = ""
      @link_to_previous_page = false

      File.open(report_file_name(destination), "w") do |f|
        f.write(report.result(b))
      end
    end

    private

    def load_template
      ERB.new(File.read(File.join(Aquatone::AQUATONE_ROOT, "templates", "#{@options[:template]}.html.erb")))
    end

    def h(unsafe)
      CGI.escapeHTML(unsafe.to_s)
    end

    def report_file_name(destination)
     File.join(destination, "dirb_report_page.html")
    end

  end
end
