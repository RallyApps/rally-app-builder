require 'fileutils'


DISABLE_JSLINT = ENV['DISABLE_JSLINT'] == 'true'

task :default => [:debug, :build]

desc "Create an app with the provided name (and optional SDK version)"
task :new, :app_name, :sdk_version do |t, args|
  args.with_defaults(:sdk_version => "2.0p")
  Dir.chdir(Rake.original_dir)

  config = Rally::AppSdk::AppConfig.new(args.app_name, args.sdk_version)
  Rally::AppSdk::AppTemplateBuilder.new(config).build
end

desc "Build a deployable app which includes all JavaScript and CSS resources inline"
task :build => [:jslint] do
  Dir.chdir(Rake.original_dir)
  Rally::AppSdk::AppTemplateBuilder.new(get_config_from_file).build_app_html
end

desc "Build a debug version of the app, useful for local development"
task :debug do
  Dir.chdir(Rake.original_dir)
  Rally::AppSdk::AppTemplateBuilder.new(get_config_from_file).build_app_html(true)
end

desc "Clean all generated output"
task :clean do
  Dir.chdir(Rake.original_dir)
  remove_files Rally::AppSdk::AppTemplateBuilder.get_auto_generated_files
end

desc "Run jslint on all JavaScript files used by this app, can be disabled by setting DISABLE_JSLINT=true."
task :jslint do |t|
  unless DISABLE_JSLINT
    Dir.chdir(Rake.original_dir)

    config = get_config_from_file
    files_to_run = config.javascript
    options = {
        "browser" => true,
        "predef" => ["Rally", "Ext"],
        "nomen" => false,
        "onevar" => false,
        "plusplus" => false
    }
    Rally::Jslint.run_jslint(files_to_run, options)
  end
end

module Rally
  module AppSdk

    ## Builds the RallyJson config file as well as the JavaScript, CSS, and HTML
    ## template files.
    class AppTemplateBuilder

      CONFIG_FILE = "config.json"
      DEPLOY_DIR = 'deploy'
      JAVASCRIPT_FILE = "App.js"
      CSS_FILE = "app.css"
      HTML = "#{DEPLOY_DIR}/App.html"
      HTML_DEBUG = "App-debug.html"
      CLASS_NAME = "CustomApp"

      def self.get_auto_generated_files
        [HTML, HTML_DEBUG]
      end

      def initialize(config)
        @config = config
      end

      def build
        fail_if_file_exists get_template_files

        @config.javascript = JAVASCRIPT_FILE
        @config.css = CSS_FILE
        @config.class_name = CLASS_NAME

        create_file_from_template CONFIG_FILE, Rally::AppTemplates::CONFIG_TPL
        create_file_from_template JAVASCRIPT_FILE, Rally::AppTemplates::JAVASCRIPT_TPL, {:escape => true}
        create_file_from_template CSS_FILE, Rally::AppTemplates::CSS_TPL
      end

      def build_app_html(debug = false, file = nil)
        @config.validate

        assure_deploy_directory_exists()

        if file.nil?
          file = debug ? HTML_DEBUG : HTML
        end
        template = debug ? Rally::AppTemplates::HTML_DEBUG_TPL : Rally::AppTemplates::HTML_TPL
        template = populate_template_with_resources(template,
                                                    "JAVASCRIPT_BLOCK",
                                                    @config.javascript,
                                                    debug,
                                                    "\"VALUE\"",
                                                    3)

        template = populate_template_with_resources(template,
                                                    "STYLE_BLOCK",
                                                    @config.css,
                                                    debug,
                                                    "<link rel=\"stylesheet\" type=\"text/css\" href=\"VALUE\">",
                                                    2)

        create_file_from_template file, template, {:debug => debug, :escape => true}
      end

      def generate_js_inline_block
        template = populate_template_with_resources(Rally::AppTemplates::JAVASCRIPT_INLINE_BLOCK_TPL, "JAVASCRIPT_BLOCK", @config.javascript, false, nil, 3)
        replace_placeholder_variables template, {}
      end

      private

      def assure_deploy_directory_exists
        mkdir DEPLOY_DIR unless  File.exists?(DEPLOY_DIR)
      end

      def get_template_files
        [CONFIG_FILE, JAVASCRIPT_FILE, CSS_FILE]
      end

      def create_file_from_template(file, template, opts = {})
        populated_template = replace_placeholder_variables template, opts
        write_file file, populated_template
      end

      def write_file(path, content)
        puts "Creating #{path}..."
        File.open(path, "w") { |file| file.write(content) }
      end

      def populate_template_with_resources(template, placeholder, resources, debug, debug_tpl, indent_level)
        block = ""
        indent_level = 1 if debug
        indent = "    " * indent_level
        separator = ""

        resources.each do |file|
          if debug
            block << separator << debug_tpl.gsub("VALUE", file)
            if is_javascript_file(file)
              separator = ",\n" + indent * 4
            else
              separator = "\n"
            end
          else
            IO.readlines(file).each do |line|
              block << indent << line.to_s.gsub(/\\'/, "\\\\\\\\'")
            end
          end
        end
        template.gsub(placeholder, block)
      end

      def replace_placeholder_variables(str, opts = {})
        # by default, we will esacpe single quotes
        escape = opts.has_key?(:escape) ? opts[:escape] : false
        debug = opts.has_key?(:debug) ? opts[:debug] : false

        str.gsub("APP_READABLE_NAME", @config.name).
            gsub("APP_NAME", escape ? escape_single_quotes(@config.name) : @config.name).
            gsub("APP_TITLE", @config.name).
            gsub("APP_SDK_VERSION", @config.sdk_version).
            gsub("APP_SDK_PATH", debug ? @config.sdk_debug_path : @config.sdk_path).
            gsub("DEFAULT_APP_JS_FILE", list_to_quoted_string(@config.javascript)).
            gsub("DEFAULT_APP_CSS_FILE", list_to_quoted_string(@config.css)).
            gsub("CLASS_NAME", @config.class_name)
      end

      def list_to_quoted_string(list)
        "\"#{list.join("\",\"")}\""
      end

      def escape_single_quotes(string)
        string.gsub("'", "\\\\\\\\'")
      end

      def is_javascript_file(file)
        file.split('.').last.eql? "js"
      end
    end


    ## Simple object wrapping the configuration of an App
    class AppConfig
      SDK_RELATIVE_URL = "/apps"
      SDK_ABSOLUTE_URL = "https://rally1.rallydev.com/apps"
      SDK_FILE = "sdk.js?wsapiVersion=1.37"
      SDK_DEBUG_FILE = "sdk-debug.js?wsapiVersion=1.37"

      attr_reader :name, :sdk_version
      attr_accessor :javascript, :css, :class_name

      def self.from_config_file(config_file)
        unless File.exist? config_file
          raise Exception.new("Could not find #{config_file}.  Did you run 'rake new[\"App Name\"]'?")
        end

        name = Rally::RallyJson.get(config_file, "name")
        sdk_version = Rally::RallyJson.get(config_file, "sdk")
        class_name = Rally::RallyJson.get(config_file, "className")
        javascript = Rally::RallyJson.get_array(config_file, "javascript")
        css = Rally::RallyJson.get_array(config_file, "css")

        config = Rally::AppSdk::AppConfig.new(name, sdk_version)
        config.javascript = javascript
        config.css = css
        config.class_name = class_name

        config
      end

      def initialize(name, sdk_version)
        @name = sanitize_string name
        @sdk_version = sdk_version
        @javascript = []
        @css = []
      end

      def javascript=(file)
        @javascript = (@javascript << file).flatten
      end

      def css=(file)
        @css = (@css << file).flatten
      end

      def validate
        @javascript.each do |file|
          raise Exception.new("Could not find JavaScript file #{file}") unless File.exist? file
        end

        @css.each do |file|
          raise Exception.new("Could not find CSS file #{file}") unless File.exist? file
        end

        class_name_valid = false
        @javascript.each do |file|
          file_contents = File.open(file, "rb").read
          if file_contents =~ /Ext.define\(\s*['"]#{class_name}['"]\s*,/
            class_name_valid = true
            break
          end
        end
        unless class_name_valid
          msg = "The 'className' property '#{class_name}' in #{Rally::AppSdk::AppTemplateBuilder::CONFIG_FILE} was not used when defining your app.\n" +
              "Please make sure that the 'className' property in #{Rally::AppSdk::AppTemplateBuilder::CONFIG_FILE} and the class name you use to define your app match!"
          raise Exception.new(msg)
        end

      end

      def sdk_debug_path
        "#{SDK_ABSOLUTE_URL}/#{@sdk_version}/#{SDK_DEBUG_FILE}"
      end

      def sdk_path
        "#{SDK_RELATIVE_URL}/#{@sdk_version}/#{SDK_FILE}"
      end
    end
  end

  class Jslint
    def self.check_for_jslint_support
      puts "Running jslint..."

      begin
        require 'rubygems'
        require 'jslint-v8'
      rescue Exception
        puts "In order to run jslint, you will need to install the 'jslint-v8' Ruby gem.\n" +
                 "You can do that by running:\n\tgem install jslint-v8\n"
        false
      end
    end

    def self.run_jslint(files_to_run, options)
      return unless check_for_jslint_support

      output_stream = STDOUT

      formatter = JSLintV8::Formatter.new(output_stream)
      runner = JSLintV8::Runner.new(files_to_run)
      runner.jslint_options.merge!(options)


      lint_result = runner.run do |file, errors|
        formatter.tick(errors)
      end

      output_stream.print "\n"
      formatter.summary(files_to_run, lint_result)
      raise "Jslint failed" unless lint_result.empty?
    end
  end

  ## Pure (very simple) Ruby JSON implementation
  module RallyJson
    class << self

      def get(file, key)
        get_value(file, key)
      end

      def get_array(file, key)
        get_array_values(file, key)
      end

      private
      def get_value(file, key)
        File.open(file, "r").each_line do |line|
          if line =~ /^\s*"#{key}"\s*:\s*"(.*)".*$/ || line =~ /^\s*"#{key}"\s*:\s*(.*)\s*$/
            return $1
          end
        end
        nil
      end

      def get_array_values(file, key)
        values = []

        in_block = false
        File.open(file).each_line do |line|
          in_block = true if line =~ /^\s*"#{key}"\s*:\s*\[/

          if in_block
            if line =~ /^\s*"#{key}"\s*:\s*\[(.*)\]/
              add_prop values, $1, key
            elsif line =~ /^\s*(".*")[,\]]?/
              add_prop values, $1, key
            end
          end

          in_block = false if in_block && line =~ /.*\][,]?/
        end

        values
      end

      def add_prop(array, values, exclude)
        values.split(',').each do |value|
          value = value.chomp.strip
          value = value.chomp[1..(value.length-2)]
          array << value unless value == exclude || value.nil?
        end
      end

    end
  end

  module AppTemplates
    ## Templates
    JAVASCRIPT_TPL = <<-END
Ext.define('CLASS_NAME', {
    extend: 'Rally.app.App',
    componentCls: 'app',

    launch: function() {
        //Write app code here
    }
});
    END

    JAVASCRIPT_INLINE_BLOCK_TPL = <<-END
JAVASCRIPT_BLOCK
            Rally.launchApp('CLASS_NAME', {
                name: 'APP_NAME'
            });
    END

    HTML_DEBUG_TPL = <<-END
<!DOCTYPE html>
<html>
<head>
    <title>APP_TITLE</title>

    <script type="text/javascript" src="APP_SDK_PATH"></script>

    <script type="text/javascript">
        Rally.onReady(function() {
            Rally.loadScripts([
                JAVASCRIPT_BLOCK
            ], function() {
                Rally.launchApp('CLASS_NAME', {
                    name: 'APP_NAME'
                })
            }, true);
        });
    </script>

STYLE_BLOCK
</head>
<body></body>
</html>
    END

    HTML_TPL = <<-END
<!DOCTYPE html>
<html>
<head>
    <title>APP_TITLE</title>

    <script type="text/javascript" src="APP_SDK_PATH"></script>

    <script type="text/javascript">
        Rally.onReady(function() {
#{JAVASCRIPT_INLINE_BLOCK_TPL}        });
    </script>

    <style type="text/css">
STYLE_BLOCK    </style>
</head>
<body></body>
</html>
    END

    CONFIG_TPL = <<-END
{
    "name": "APP_READABLE_NAME",
    "className": "CustomApp",
    "sdk": "APP_SDK_VERSION",
    "javascript": [
        DEFAULT_APP_JS_FILE
    ],
    "css": [
        DEFAULT_APP_CSS_FILE
    ]
}
    END

    CSS_TPL = <<-END
.app {
     /* Add app styles here */
}
    END
  end
end

## Helpers
def get_config_from_file
  config_file = Rally::AppSdk::AppTemplateBuilder::CONFIG_FILE
  Rally::AppSdk::AppConfig.from_config_file(config_file)
end

def remove_files(files)
  files.map { |f| File.delete(f) if File.exists?(f) }
end

def fail_if_file_exists(files)
  files.each do |file|
    raise Exception.new "I found an existing app file - #{file}.  If you want to create a new app, please remove this file!" if File.exists? file
  end
end

def sanitize_string(value)
  value.gsub(/[^a-zA-Z0-9 \-_\.']/, "")
end