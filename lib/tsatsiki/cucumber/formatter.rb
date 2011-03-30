require 'cucumber/formatter/gherkin_formatter_adapter'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/json_formatter'
require File.expand_path('../../web_socket/simple_client', __FILE__)


module Tsatsiki
  module Cucumber
    class Formatter < ::Cucumber::Formatter::GherkinFormatterAdapter
      
      def initialize(step_mother, io, options)
        @options = options
        @tsatsiki_url = ENV['TSATSIKI_URL']
        @project_id = ENV['TSATSIKI_PROJECT_ID']
        
        puts "="*80, "connecting to #{@tsatsiki_url}", "="*80
        @websocket = WebSocket::SimpleClient.new(@tsatsiki_url)
        
        send_message('started', {:project_id => @project_id})
        at_exit do
          send_message('finished', {:project_id => @project_id})
        end
        
        super(Gherkin::Formatter::JSONFormatter.new(nil), false)
      end
      
      
      
      def after_feature(feature)
        super
        p @gf.gherkin_object
        send_message('result', {
          :project_id => @project_id,
          :feature_file => feature.file,
          :scenarios => format_scenarios(@gf.gherkin_object)
        })
      end
      
      
      
    private
      
      
      
      def send_message(message, data={})
        p data
        send_data({
          :message => message,
          :data => data
        }.to_json)
      end
      
      def send_data(data)
        @websocket.send(data)
      end
      
      
      
      def format_scenarios(results)
        results['elements'].map do |element|
          {
            :line => element['line'],
            :status => get_status_of_steps(element['steps'])
          }
        end
      end
      
      def get_status_of_steps(steps)
        statuses = steps.map {|step| step['result']['status']}
        status = nil
        begin; status = statuses.shift; end while(status == "passed")
        status || "passed"
      end
      
      
      
    end
  end
end
