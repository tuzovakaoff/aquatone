require 'rspec'

describe "Behaviour" do
  def make_file_basename(host, port, domain)
    "#{domain}__#{host}__#{port}".downcase.gsub(".", "_")
  end

  tasks = ENV['tasks']
  assessment = ENV['assessment']
  tasks = Array.class_eval (tasks)
  tasks.shuffle.each do |host, port, domain|
    it "should send request to #{host}#{domain}:#{port}" do

        file_basename = make_file_basename(host, port, domain)
        url = Aquatone::UrlMaker.make(host, port)
        html_destination = File.join(assessment, "html", "#{file_basename}.html")
        headers_destination = File.join(assessment, "headers", "#{file_basename}.txt")
        screenshot_destination = File.join(assessment, "screenshots", "#{file_basename}.png")
        visit = Aquatone::Browser.visit(url, domain, html_destination, headers_destination, screenshot_destination, :timeout => options[:timeout])



        if visit['success']
          output("#{green('Processed:')} #{Aquatone::UrlMaker.make(host, port)} (#{domain}) - #{visit['status']}\n")
          @successful += 1
        else
          output("   #{red('Failed:')} #{Aquatone::UrlMaker.make(host, port)} (#{domain}) - #{visit['error']} #{visit['details']}\n")
          @failed += 1
        end


        expect(visit['code']).to be_in (["404","403"])

      end


    end

  end