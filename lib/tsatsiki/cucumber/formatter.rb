require File.expand_path('../../web_socket/simple_client', __FILE__)


module Tsatsiki
  module Cucumber
    class Formatter
      
      
      
      def initialize(step_mother, io, options)
        @options = options
        @tsatsiki_url = ENV['TSATSIKI_URL']
        @project_id = ENV['TSATSIKI_PROJECT_ID']
        
        puts "="*80, "[tsatsiki-cucumber-formatter] connecting to #{@tsatsiki_url}", "="*80
        @websocket = WebSocket::SimpleClient.new(@tsatsiki_url)
        
        send_message('started', {:project_id => @project_id})
        at_exit do
          send_message('finished', {:project_id => @project_id})
        end
      end
      
      
      
      def before_feature(feature)
        
        # Tsatsiki identifies Scenarios and ScenarioOutlines by their index
        # within a feature file rather than by their line number. One reason
        # for this is that the s-expression for ScenarioOutlines does not
        # indicate their line number.
        map_line_numbers_to_indexes(feature)
      end
      
      # `element` is either Background, Scenario, or ScenarioOutline
      # c.f. http://rdoc.info/github/aslakhellesoy/cucumber/master/Cucumber/Ast/FeatureElement
      def after_feature_element(element)
        unless is_background?(element)
          
          klass = element.class.name[/[^:]*$/]
          status = get_status(element)
          file = element.feature.file
          index = get_index_from_line_number(element.gherkin_statement.line)
          
          puts "#{klass} \"#{element.name}\": <#{status}>"
          
          send_message('result', {
            :project_id => @project_id,
            :feature_file => file,
            :index => index,
            :status => status
          })
          
        end
      end
      
      # after_steps(Cucumber::Ast::StepCollection)
      
      
      
    private
      
      
      
      def is_background?(element)
        element === ::Cucumber::Ast::Background
      end
      
      
      
      def map_line_numbers_to_indexes(feature)
        whole_feature = ::Cucumber::FeatureFile.new(feature.file, nil).parse([], {})
        @indexes_by_line = {}
        index = 0
        whole_feature.init
        whole_feature.instance_variable_get(:@feature_elements).each do |element|
          unless is_background?(element)
            @indexes_by_line[element.gherkin_statement.line] = (index += 1)
          end
        end
        @indexes_by_line
      end
      
      def get_index_from_line_number(line)
        @indexes_by_line[line]
      end
      
      
      
      def send_message(message, data={})
        send_data({
          :message => message,
          :data => data
        }.to_json)
      end
      
      def send_data(data)
        @websocket.send(data)
      end
      
      
      
      def get_status(element)
        return :undefined if element.try(:raw_steps).empty? # [Cucumber::Ast::Step]
        
        case element
        when ::Cucumber::Ast::Scenario:           get_status_of_scenario(element)
        when ::Cucumber::Ast::ScenarioOutline:    get_status_of_scenario_outline(element)
        else
          raise("unexpected feature element: #{element.class.name}")
        end
      end
      
      def get_status_of_scenario(element)
        element.status
      end
      
      def get_status_of_scenario_outline(element)
        status = :passed
        any_examples = false
        
        element.each_example_row do |row| # Cucumber::Ast::OutlineTable::ExampleRow
          any_examples = true
          return row.status unless (row.status == :passed)
        end
        
        return any_examples ? :passed : :undefined
      end
      
      
      
    end
  end
end
