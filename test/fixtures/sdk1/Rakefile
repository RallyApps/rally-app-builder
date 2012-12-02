require 'fileutils'
require 'net/http'
require 'uri'
require 'json'

ENABLE_JSLINT = ENV['ENABLE_JSLINT'] == 'true'

task :default => [:debug, :build]

desc "Create an app with the provided name (and optional SDK version and rally server)"
task :new, :app_name, :sdk_version, :server do |t, args|
  args.with_defaults(:sdk_version => "2.0p5")
  Dir.chdir(Rake.original_dir)
  puts "Generating new #{args[:sdk_version]} Rally App Development framework..."
  config = Rally::AppSdk::AppConfig.new(args.app_name, args.sdk_version, args.server)
  Rally::AppSdk::AppTemplateBuilder.new(config).build

  puts "Finished!"
  puts
  puts "To build your app, edit App.js then run '$rake build'."
  puts "To deploy your app, edit deploy.json then run '$rake deploy'."
  puts
  puts "* Note: deploy.json stores login credentials and will be ignored by git."
  puts
end

desc "Build a deployable app which includes all JavaScript and CSS resources inline"
task :build => [:jslint] do
  puts "Building App..."
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

desc "Deploy an app to a Rally server"
task :deploy => ["deploy:app"] do
end

namespace "deploy" do
  # wrapped with top-level 'deploy' target as a convenience
  task :app => ["rake:build"] do
    config = get_config_from_file
    app_filename = Rally::AppSdk::AppTemplateBuilder::HTML
    deployr = Rally::AppSdk::Deployr.new(config, app_filename)
    deployr.deploy
  end

  desc "Deploy a debug app to a Rally server"
  task :debug => ["rake:debug"] do
    config = get_config_from_file
    app_filename = Rally::AppSdk::AppTemplateBuilder::HTML_DEBUG
    deployr = Rally::AppSdk::Deployr.new(config, app_filename)
    deployr.deploy
  end

  desc "Display deploy information"
  task :info do
    config = get_config_from_file
    app_filename = Rally::AppSdk::AppTemplateBuilder::HTML
    deployr = Rally::AppSdk::Deployr.new(config, app_filename)
    deployr.info
  end
end

desc "Run jslint on all JavaScript files used by this app, can be enabled by setting ENABLE_JSLINT=true."
task :jslint do |t|
  if ENABLE_JSLINT
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

    # Name: Deployr
    # Description: Class responsible for deploying Your app to a Rally server.
    #              Already deployed? Your page will just be updated with new app source.
    #              For new apps, a new single-layout page with a panel will be created.
    #              Simply enter connection details in the config file.
    #
    #              For convenience, you can specify the name of your Rally project in
    #              the config file.  If that name is not unique, you must set the project OID
    #              instead.  If both are specific, only the OID is used.  To find a project OID:
    #              [Rally > Setup > Workspace & Projects > hover project link > copy link location]
    #              eg. https://<server>/#/699319d/detail/project/699319 --> 699319 is the Project OID.
    #
    # Security: Connection & credential info should be safely located (chmod 600) in deploy.json.
    #
    # Config:
    #         deploy.json
    #         { 
    #          ...
    #          "server": "http://rally1.rallydev.com"   # or another instance
    #          "username": "someone@domain.com"         # rally login name
    #          "password": "S3cr3tS4uce"                # rally login password
    #          "project": "Some Project"                # [optional] conveninence to set project name to deploy to
    #          "projectOid": "123"                      # id of the project to deploy new page (can omit if setting 'project')
    #          "pageOid.cached": "456"                   # !internal! cached page reference generated on 1st deploy
    #          "panelOid.cached": "789"                  # !internal! cached panel reference generated on 1st deploy
    #         }
    #
    # Workflow Overview:
    #
    #         New App:
    #          Login > Create Page > [Set Cache] > Set Layout > Add Empty Panel > Upload Content
    #         Existing App:
    #          Login > [Get Cache] > Upload Content
    #
    # Manual Testing: The following shell curl statements, developed as a prelude to this Class,
    #                 provide an alternate example for (manual) testing.  The uri's, schemes, and
    #                 params in this class were taken directly from the curl statements.  Note that
    #                 cookies.txt file used to pass around the session info.
    #
    #         LOGIN
    #          curl --location --cookie-jar cookies.txt --data-urlencode "j_username=<user>" --data-urlencode "j_password=<passwd>"
    #               https://demo01.rallydev.com/slm/platform/j_platform_security_check.op
    #         CREATE BLANK PAGE
    #           curl --cookie cookies.txt
    #                --data "name=foopage&type=DASHBOARD&timeboxFilter=none&pid=myhome&editorMode=create&cpoid=699319&projectScopeUp=false&projectScopeDown=false&version=0"
    #                "https://demo01.rallydev.com/slm/wt/edit/create.sp"
    #         SET PAGE LAYOUT (SINGLE)
    #           curl --cookie cookies.txt
    #             "https://demo01.rallydev.com/slm/dashboardSwitchLayout.sp?cpoid=699319&layout=SINGLE&dashboardName=myhome2246145&_slug=/custom/2246145"
    #         GET PANEL DEFINITION
    #           curl --cookie cookies.txt
    #                "https://demo01.rallydev.com/slm/panel/getCatalogPanels.sp?cpoid=&ignorePanelDefOids&gesture=getcatalogpaneldefs&slug=/custom/2246145"
    #         CREATE PANEL
    #           curl --location --cookie cookies.txt
    #                --data "panelDefinitionOid=739274&col=0&index=0&dashboardName=myhome224615"
    #                "https://demo01.rallydev.com/slm/dashboard/addpanel.sp?cpoid=699319&_slug=/custom/2246145"
    #         UPLOAD PANEL CONTENT
    #           curl --cookie cookies.txt
    #             --data "oid=2246150&dashboardName=myhome2246145&settings={'title':'my title','content':'my content'}"
    #             "https://demo01.rallydev.com/slm/dashboard/changepanelsettings.sp?cpoid=699319&_slug=/custom/2246145"
    #
    class Deployr

      def initialize(config, app_filename)
        @config = config                      # source of truth
        @server = config.server
        @port = "443"                         # SSL default port
        @username = config.username
        @password =config.password
        @project_oid = config.project_oid     # id of project to deploy app to
        @project = config.project             # [optional] name of project to deploy app to
        @page_oid = config.page_oid           # id of existing page for updates
        @panel_oid = config.panel_oid         # id of existing panel, on page, for updates
        @tab_name = 'myhome'                  # internal name for 'My Home' application tab (used in http requests)
        @tab_display_name = 'MyHome'          # display name 'My Home' application tab
        @app_name = config.name               # user provided name for their app
        @app_filename = app_filename          # locally built app
        @session_cookie = nil                 # required during all server communication; defined after login
      end

      def deploy

        raise "Unable to deploy.  Missing values in deploy.json config file. Aborting..." if !@config.deployable?

        puts "Deploying to Rally..."
        login  # obtains session info
        resolve_project  # determine if using oid or name from config

        puts "* Server:   #{@server}"
        puts "* Username: #{@username}"
        puts "* Project:  #{@project}"

        if !page_exists?
          create_page
          puts "> Created '#{@tab_display_name} > #{@app_name}'page"
        end

        upload_app
        puts "> Uploaded code to '#{@app_name}' page"

        write_local_html_app
        puts "* Local Test File: #{Rally::AppSdk::AppTemplateBuilder::HTML_LOCAL}"
        puts "* Remote Test URL:#{@server}/#/#{@project_oid}/custom/#{@page_oid}"
        puts "Finished!"
      end

      def info
        login  # obtains session info
        resolve_project  # determine if using oid or name from config

        is_deployed = !@page_oid.nil?   # if page_oid is cached, then we have deployed

        puts "    Status: #{(is_deployed)? '* ': '* Not '}Deployed *"
        puts "      Page: #{@server}/#/#{@project_oid}/custom/#{@page_oid}" if is_deployed
        puts "    Server: #{@server}"
        puts " Page Name: #{@app_name}"
        puts "  Username: #{@username}"
        puts "   Project: #{@project}" if !@project.nil?
        puts "ProjectOid: #{@project_oid}" if !@project_oid.nil?
      end

      private

      # Login to Rally and obtain session id
      # Developer note: After posting login creds, Rally immediately issues a 302 redirect
      def login
        form_data = {"j_username" => @username, "j_password" => @password}
        response = rally_post("/slm/platform/j_platform_security_check.op", form_data, true)
        # essential for subsequent calls to rally to authenticate internally
        @session_cookie = get_session_cookie(response)
      end

      # Determines if the app has already been uploaded to an existing page.
      # When a page is first deployed, the oid is saved in the config file.  This oid is
      # then used in subsequent deploys as a 'cached' value to simply update the page.  Even with
      # a cached value, we do a sanity check to verify the page _really_ exists.
      #
      # Developer Note:
      #   * direct 'page' url format: https://demo01.rallydev.com/#/{project_oid}/custom/{dashboard_oid}
      #                               https://demo01.rallydev.com/#/699319/custom/2248290
      def page_exists?
        # not cached
        return false if @page_oid.nil?

        # even cached, lets verify page still exists
        response = rally_get("/#/#{@project_oid}/custom/#{@page_oid}")
        return true if response.class == Net::HTTPOK

        # cached page that DNE means user deleted it; lets just create again
        return false
      end

      def create_page
        # new page with no panels
        @page_oid = create_blank_page
        @config.add_persistent_deploy_property("pageOid.cached", @page_oid) # cache page oid for subsequent deploys

        # set 'single' layout
        set_page_layout

        # container on page for app code
        @panel_oid = create_empty_panel
        @config.add_persistent_deploy_property("panelOid.cached", @panel_oid)  # cache panel oid for subsequent deploys
      end

      # Extract Rally session cookie from response
      def get_session_cookie(response)
        response.get_fields('set-cookie').each do |cookie|
          return cookie if cookie =~ /JSESSIONID/
        end
      end

      # Create new page.
      # Developer Note: After creating a page, the oid of the page is in the resulting html.
      #                 We need this oid for future reference to the page.  Since html != xml,
      #                 regex to the rexue.  While this is a lava pit in general, the match
      #                 string needed is specific.   Also prevented gems e.g. nokogiri, etc.
      def create_blank_page
        form_data = {"name" => @app_name,
                     "type" => 'DASHBOARD',
                     "timeboxFilter" => "none",
                     "pid" => @tab_name,
                     "editorMode" => "create",
                     "cpoid" => @project_oid,
                     "version" => 0}
        response = rally_post("/slm/wt/edit/create.sp", form_data)

        # Looking for page OID html element e.g. <input type="hidden" name="oid" value="2247529"/>
        match_data = /<input\ +type="hidden"\ +name="oid"\ +value="(\d+)"\/>/.match(response.body)

        # TODO: error handling if page Id not found
        page_oid = match_data[1]

        return page_oid

      end

      # Create empty panel to place app source code
      def create_empty_panel
          # Lookup panel meta
          path = "/slm/panel/getCatalogPanels.sp"
          params = {:cpoid => @project_oid,
                    :_slug => "/custom/#{@page_oid}",
                    :ignorePanelDefOids => ''}  # empty ignorePanelDefOids apparently is required
          response = rally_get(path, params)

          panels = JSON.parse(response.body)
          custom_html_panel_oid = nil
          panels.each do |panel|
            custom_html_panel_oid = panel['oid'] if panel['title'] == "Custom HTML"
          end
          
          # Create new panel
          request_path = "/slm/dashboard/addpanel.sp"
          params = {:cpoid => @project_oid, :_slug => "/custom/#{@page_oid}"}
          path = construct_get(request_path, params)

          form_data = {"panelDefinitionOid" => custom_html_panel_oid,
                       "dashboardName" => "#{@tab_name}#{@page_oid}",
                       "col" => 0,
                       "index" => 0}
          response = rally_post(path, form_data)

          # response is json that just contains oid e.g. {"oid": "1234556"}
          panel_oid = JSON.parse(response.body)['oid']

          return panel_oid
      end

      # Uploads application source
      def upload_app
          request_path = "/slm/dashboard/changepanelsettings.sp"
          params = {:cpoid => @project_oid,
                    :projectScopeUp => false,
                    :projectScopeDown => true,
                    :_slug => "/custom/#{@page_oid}"}
          path = construct_get(request_path, params)

          app_html = File.read(@app_filename)
          panel_settings = {:title => @app_title, :content => app_html}

          form_data = {"oid" => @panel_oid,
                       "dashboardName" => "#{@tab_name}#{@page_oid}",
                       "settings" => JSON.generate(panel_settings)}
          response = rally_post(path, form_data)
      end

      # Set layout of page
      def set_page_layout
          path = "/slm/dashboardSwitchLayout.sp"
          params = {:cpoid => @project_oid,
                    :layout => "SINGLE",
                    :dashboardName => "#{@tab_name}#{@page_oid}",
                    :_slug => "/custom/#{@page_oid}",}
          response = rally_get(path, params)
      end

      def write_local_html_app
        filename = Rally::AppSdk::AppTemplateBuilder::HTML_LOCAL
        app_width_default = 1024
        scope_up = false
        scope_down = false
        content  = "<!-- -------------------------------------------------------------- -->\n"
        content += "<!-- DO NOT EDIT: This file is auto-generated by rake 'deploy' task -->\n"
        content += "<!-- -------------------------------------------------------------- -->\n"
        content += "<!-- #{filename} makes it super fast to test the fully built app in a single panel -->\n"
        content += "<!-- without having to load the entire rally page.  Simply load #{filename} in -->\n"
        content += "<!-- a local browser to experience the speed! (e.g. file:///path/to/#{filename}) -->\n"
        content += "<html><body>\n"
        content += "<iframe width='100%' height='100%' frameborder='0'\n"
        content += "src='#{@server}/slm/panel/html.sp?width=#{app_width_default}&panelOid=#{@panel_oid}&cpoid=#{@project_oid}&projectScopeUp=#{scope_up}&projectScopeDown=#{scope_down}&isEditable=true'></iframe>\n"
        content += "</body></html>"
        File.open(filename, "w") { |file| file.write(content) }
        puts "> Created #{filename}"
      end

      # Determine project reference (oid) either using a given oid or looking up a given project name (in config).
      # This takes into consideration error handling for finding > 1 project with the same name.  Lets
      # just assume that 80% of the time, project names are unique and it's handy to set in the config file.
      # All others with conflicting names will just have to manually lookup the project oid and set in config file.
      def resolve_project 

          # oid not given; lookup by name
          if @project_oid.nil? || @project_oid.empty?

            # no project settings (oid or name) found - error
            if @project.nil? || @project.empty?
              puts "** Error: No project oid or name found in config file."
              puts "Exiting..."
              exit 1
            end

            # lookup oid for given name
            path = "/slm/webservice/1.36/project.js"
            params = {"query" => "(Name%20%3D%20%22#{URI.encode(@project)}%22)",
                      "fetch" => "ObjectID"}
            response = rally_get(path, params)
            results = JSON.parse(response.body)
            result_count = results["QueryResult"]["TotalResultCount"].to_i

           if result_count == 0
             puts "** Error: Unable to find '#{@project}' in Rally.  Check config file."
             puts "Exiting..."
             exit 1
           elsif result_count > 1
             puts "** Error: Multiple projects named '#{@project}' found in Rally.  Set project_oid in config file."
             puts "Exiting..."
             exit 1
           end

            # grab project oid from single result in lookup
            project_oid = results["QueryResult"]["Results"][0]["ObjectID"]

            # verify parsed project oid is all digits
            if project_oid.to_s !~ /\d+/ then
              puts "** Internal Error: Unable to parse project oid from name lookup."
              puts "** Debugging: There should be project info (e.g. 'ObjectID') in the results."
              puts results["QueryResult"]["Results"]
              puts "Exiting..."
              exit 1
            end

            @project_oid = project_oid

          # oid given, lookup name
          else
            path = "slm/webservice/1.36/project/#{@project_oid}.js"
            params = {"fetch" => "Name"}
            response = rally_get(path, params)
            results = JSON.parse(response.body)
            @project = results["Project"]["Name"]
          end
      end

      # Utility to concatenate the GET request params after the given request path
      # Given params={:foo => "bar", "baz" => "quux"} generate 'path?foo=bar?baz=quux'
      def construct_get(path, params)
          path = "#{path}?".concat(params.collect { |k,v| "#{k}=#{v}" }.join('&'))
      end

      # Perform HTTP GET to Rally with given uri path
      def rally_get(path, params = {})

        # format get params on end of path
        path = construct_get(path, params) if !params.empty?
        # ensure prepended slash
        path = "/#{path}" if path[0] != '/'

        uri = URI.parse(@server + ":" + @port + path)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri, {'Cookie' => "#{@session_cookie}"})
        begin
          response = http.request(request)
          # bad username/password login; HTTPUnauthorized
          raise "Unauthorized access.  Check credentials in config file." if response.code == "401"
        rescue Exception => e
          puts "** Error: Problem connecting to Rally server '#{@server}'."
          puts "** Reason: #{e.message}"
          puts "Exiting..."
          exit 1
        end
        return response
      end

      # Perform HTTP POST to Rally with given uri path
      def rally_post(path, form_data, login = false)
        path = "/#{path}" if path[0] != '/'    # ensure prepended slash
        uri = URI.parse(@server + ":" + @port + path)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        headers = {'Cookie' => @session_cookie} unless login   # don't even have cookies until -after- login :)
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.set_form_data(form_data)
        begin
          response = http.request(request)
          # if session is bad (usually credentials) rally commonly responds with 302
          raise "Invalid session and/or credentials.  Check username/password in config file." if response.code == "302" && !login
          # bad username/password login; HTTPUnauthorized
          raise "Unauthorized access.  Check credentials in config file." if response.code == "401"
        rescue Exception => e
          if login
            puts "** Error: Unable to login to Rally server '#{@server}'."
          else
            puts "** Error: Problem connecting to Rally server '#{@server}'."
          end
          puts "** Reason: #{e.message}"
          puts "Exiting..."
          exit 1
        end
        return response
      end

    end

    ## Builds the RallyJson config file as well as the JavaScript, CSS, and HTML
    ## template files.
    class AppTemplateBuilder
      include Rake::DSL

      CONFIG_FILE = "config.json"
      DEPLOY_FILE = "deploy.json"
      GITIGNORE_FILE = ".gitignore"
      DEPLOY_DIR = 'deploy'
      JAVASCRIPT_FILE = "App.js"
      CSS_FILE = "app.css"
      HTML = "#{DEPLOY_DIR}/App.html"
      HTML_DEBUG = "App-debug.html"
      HTML_LOCAL = "App-local.html"
      CLASS_NAME = "CustomApp"

      attr_reader :html_template_file

      def self.get_auto_generated_files
        [HTML, HTML_DEBUG]
      end

      def initialize(config)
        @config = config
        @html_template_file = @config.name + ".template.html"
      end

      def build
        fail_if_file_exists get_template_files

        @config.javascript = JAVASCRIPT_FILE
        @config.css = CSS_FILE
        @config.class_name = CLASS_NAME

        create_file_from_template CONFIG_FILE, Rally::AppTemplates::CONFIG_TPL
        create_file_from_template DEPLOY_FILE, Rally::AppTemplates::DEPLOY_TPL
        create_file_from_template GITIGNORE_FILE, Rally::AppTemplates::GITIGNORE_TPL

        # The Javascript and CSS structure are different between SDK 1 and SDK 2
        if @config.sdk_version.include? "1."
          create_file_from_template JAVASCRIPT_FILE, Rally::AppTemplates::JAVASCRIPT_SDK1_TPL, {:escape => true}
          create_file_from_template CSS_FILE, Rally::AppTemplates::CSS_SDK1_TPL 
          create_file_from_template @html_template_file, Rally::AppTemplates::HTML_FILE_TPL unless File.exists? html_template_file
        else
          create_file_from_template JAVASCRIPT_FILE, Rally::AppTemplates::JAVASCRIPT_TPL, {:escape => true}
          create_file_from_template CSS_FILE, Rally::AppTemplates::CSS_TPL
        end
      end

      def build_app_html(debug = false, file = nil)
        @config.validate

        assure_deploy_directory_exists()

        if file.nil?
          file = debug ? HTML_DEBUG : HTML
        end

        # HTML templates are different betweeen SDK 1 and SDK 2 apps
        html_tpl = ""

        if @config.sdk_version.include? "1."
          template = debug ? Rally::AppTemplates::HTML_DEBUG_SDK1_TPL : Rally::AppTemplates::HTML_SDK1_TPL
          html_tpl = add_placeholders_to_html_template_file(template, @html_template_file, debug)
        else
          template = debug ? Rally::AppTemplates::HTML_DEBUG_TPL : Rally::AppTemplates::HTML_TPL
        end

        template = populate_html_template_with_resources(template,
                                                        "HTML_SDK1_BLOCK",
                                                        html_tpl,
                                                        debug,
                                                        "VALUE")

        # Indents are a bit different between SDK 1 and 2 files with Javascript blocks
        js_indent = (@config.sdk_version.include? "1.") ? 1 : 3

        template = populate_template_with_resources(template,
                                                    "JAVASCRIPT_BLOCK",
                                                    @config.javascript,
                                                    debug,
                                                    "\"VALUE\"",
                                                    js_indent)

        template = populate_template_with_resources(template,
                                                    "STYLE_BLOCK",
                                                    @config.css,
                                                    debug,
                                                    "<link rel=\"stylesheet\" type=\"text/css\" href=\"VALUE\">",
                                                    1)

        template = populate_template_with_resources(template,
                                                    "JAVASCRIPT_DEBUG_BLOCK",
                                                    @config.javascript,
                                                    debug,
                                                    "<script type=\"text/javascript\" src=\"VALUE\"></script>",
                                                    2)

        create_file_from_template file, template, {:debug => debug, :escape => true}
      end

      def generate_js_inline_block
        template = populate_template_with_resources(Rally::AppTemplates::JAVASCRIPT_INLINE_BLOCK_TPL, "JAVASCRIPT_BLOCK", @config.javascript, false, nil, 3)
        replace_placeholder_variables template, {}
      end

      private

      def assure_deploy_directory_exists
        mkdir DEPLOY_DIR unless File.exists?(DEPLOY_DIR)
      end

      # These template files cannot exist when creating a new project. *.template.html is an exception and not in this list
      def get_template_files
        [CONFIG_FILE, DEPLOY_FILE, JAVASCRIPT_FILE, CSS_FILE, HTML_DEBUG, HTML_LOCAL]
      end

      def create_file_from_template(file, template, opts = {})
        populated_template = replace_placeholder_variables template, opts
        write_file file, populated_template
      end

      def write_file(path, content)
        File.open(path, "w") { |file| file.write(content) }
        puts "> Created #{path}"
      end

      def add_placeholders_to_html_template_file(template, resource, debug)
        tpl_file = ""

        File.open(resource, "r") do |file|
          file.each_line do |line|
            # This will replace the placeholder App SDK include in the template file
            if line.include? "src=\"/apps/"
              sdk_src_path = debug ? @config.sdk_debug_path : @config.sdk_path
              line = "  " + "<script type =\"text/javascript\" src=\"#{sdk_src_path}\"></script>" + "\n"
            end

            tpl_file = tpl_file + line

            # This will add in all other scripts from the config file immediately after the SDK include
            if line.include? "sdk.js"
              tpl_file += "  " + "JAVASCRIPT_DEBUG_BLOCK" + "\n" + "  " + "STYLE_BLOCK" + "\n" if debug
              tpl_file += "  " + "<script type =\"text/javascript\">" + "\n" + "JAVASCRIPT_BLOCK" + "\n" + "  " + "</script>" + "\n\n" + "  " + "<style type=\"text/css\">" + "\n" + "    " + "STYLE_BLOCK" + "\n" + "  " + "</style>" + "\n" unless debug
            end
          end
        end
        tpl_file
      end

      def populate_html_template_with_resources(template, placeholder, string_tpl, debug, debug_tpl)
        block = ""

        if debug
           block << "" << debug_tpl.gsub("VALUE"){string_tpl} << ""
        else
          lines = string_tpl.split("\n")

          lines.each do |line|
            block << line.to_s.gsub(/\\'/, "\\\\\\\\'") << "\n"
          end
        end

        template.gsub(placeholder){block}
      end

      def populate_template_with_resources(template, placeholder, resources, debug, debug_tpl, indent_level)
        block = ""
        indent_level = 1 if debug
        indent = "    " * indent_level
        separator = ""

        resources.each do |file|
          if debug
            block << separator << debug_tpl.gsub("VALUE"){file}

            # Commas in a SDK1 HTML file results in incorrect HTML formatting
            if is_javascript_file(file) and not @config.sdk_version.include? "1."
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
        template.gsub(placeholder){block}
      end

      def replace_placeholder_variables(str, opts = {})
        # by default, we will esacpe single quotes
        escape = opts.has_key?(:escape) ? opts[:escape] : false
        debug = opts.has_key?(:debug) ? opts[:debug] : false

        str.gsub("APP_READABLE_NAME", @config.name).
            gsub("APP_NAME", escape ? escape_single_quotes(@config.name) : @config.name).
            gsub("APP_TITLE", @config.name).
            gsub("APP_SDK_VERSION", @config.sdk_version).
            gsub("APP_SERVER", @config.server).
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
      SDK_FILE = "sdk.js"
      SDK_DEBUG_FILE = "sdk-debug.js"
      DEFAULT_SERVER = "https://rally1.rallydev.com"

      attr_reader :name, :sdk_version, :server, :sdk_file, :sdk_debug_file
      attr_accessor :javascript, :css, :class_name
      attr_accessor :deploy_server, :username, :password, :project, :project_oid, :page_oid, :panel_oid

      def self.from_config_file(config_file, deploy_file)
        unless File.exist? config_file
          raise Exception.new("Could not find #{config_file}.  Did you run 'rake new[\"App Name\"]'?")
        end

        name = Rally::RallyJson.get(config_file, "name")
        sdk_version = Rally::RallyJson.get(config_file, "sdk")
        server = Rally::RallyJson.get(config_file, "server")
        class_name = Rally::RallyJson.get(config_file, "className")
        javascript = Rally::RallyJson.get_array(config_file, "javascript")
        css = Rally::RallyJson.get_array(config_file, "css")

        if File.exist? deploy_file
          deploy_server = Rally::RallyJson.get(deploy_file, "server")
          username = Rally::RallyJson.get(deploy_file, "username")
          password = Rally::RallyJson.get(deploy_file, "password")
          project_oid = Rally::RallyJson.get(deploy_file, "projectOid")
          project = Rally::RallyJson.get(deploy_file, "project")
          page_oid = Rally::RallyJson.get(deploy_file, "pageOid.cached")
          panel_oid = Rally::RallyJson.get(deploy_file, "panelOid.cached")

          raise "Error: Deploy server not found in deploy.json" if deploy_server.nil?
          raise "Error: Username not found in deploy.json" if username.nil?
          raise "Error: Password not found in deploy.json" if password.nil?
          raise "Error: Project name or OID not found in deploy.json" if project_oid.nil? && project.nil?
        end

        config = Rally::AppSdk::AppConfig.new(name, sdk_version, server, config_file, deploy_file)
        config.javascript = javascript
        config.css = css
        config.class_name = class_name
        config.deploy_server = deploy_server
        config.username = username
        config.password = password
        config.project_oid = project_oid
        config.project = project
        config.page_oid = page_oid
        config.panel_oid = panel_oid
        config
      end

      def initialize(name, sdk_version, server = nil, config_file = nil, deploy_file = nil)
        @name = sanitize_string name
        @sdk_version = sdk_version
        @server = set_https(server || DEFAULT_SERVER)
        @sdk_file = "sdk.js"
        @sdk_debug_file = (@sdk_version.include? "1.") ? "sdk.js?debug=true" : "sdk-debug.js" 
        @config_file = config_file
        @deploy_file = deploy_file
        @javascript = []
        @css = []
       
        if server.nil?
          puts "Defaulting to: #{@server}"
          puts "(!) You can specify \"server\": \"https://xxx.rallydev.com\" in config.json"
        end
      end

      def javascript=(file)
        @javascript = (@javascript << file).flatten
      end

      def css=(file)
        @css = (@css << file).flatten
      end

      # Add new name/value pair to the deploy config file
      def add_persistent_deploy_property(name, value)
        add_persistent_property(@deploy_file, name, value)
      end

      # Utility to add name/value pair to given config file
      def add_persistent_property(file, name, value)
        current_config = File.read(file)
        rconfig = JSON.parse(current_config)
        rconfig[name] = value
        File.open(file, 'w') {|f| f.write(JSON.pretty_generate(rconfig))}
      end

      def validate
        @javascript.each do |file|
          raise Exception.new("Could not find JavaScript file #{file}") unless File.exist? file
        end

        @css.each do |file|
          raise Exception.new("Could not find CSS file #{file}") unless File.exist? file
        end

        unless @sdk_version.include? "1."
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
      end

      def deployable?
        (File.exist? @deploy_file) \
          && !@deploy_server.nil? && !@deploy_server.empty? \
          && !@username.nil? && !@username.empty? \
          && !@password.nil? && !@password.empty?
      end

      def sdk_debug_path
        "#{@server}/apps/#{@sdk_version}/#{@sdk_debug_file}"
      end

      def sdk_path
        "/apps/#{@sdk_version}/#{@sdk_file}"
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
    HTML_FILE_TPL = <<-END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- Copyright (c) #{Time.new.strftime("%Y")} Rally Software Development Corp. All rights reserved -->
<html>
<head>
  <title>APP_TITLE</title>
  <meta name="Name" content="App: APP_READABLE_NAME" />
  <meta name="Version" content="#{Time.new.strftime("%Y.%m.%d")}" />
  <meta name="Vendor" content="Rally Software" />

  <script type="text/javascript" src="APP_SDK_PATH"></script>

  <script type="text/javascript">
    function onLoad() {
      var appCustom = new APP_NAME();
      appCustom.display(dojo.body());
    }

    rally.addOnLoad(onLoad);
  </script>
</head>

<body></body>
</html>
    END

    JAVASCRIPT_TPL = <<-END
Ext.define('CLASS_NAME', {
    extend: 'Rally.app.App',
    componentCls: 'app',

    launch: function() {
        //Write app code here
    }
});
    END

    JAVASCRIPT_SDK1_TPL = <<-END
function APP_TITLE() {
  var that = this;
  this.display = function(element) {
    // App code goes here...
  }; 
}
    END

    JAVASCRIPT_INLINE_BLOCK_TPL = <<-END
JAVASCRIPT_BLOCK
            Rally.launchApp('CLASS_NAME', {
                name: 'APP_NAME'
            });
    END

    JAVASCRIPT_INLINE_BLOCK_SDK1_TPL = <<-END
   <script type="text/javascript">
JAVASCRIPT_BLOCK
    </script>

    <script type="text/javascript">
      function onLoad() {
          var appCustom = new APP_NAME();
          appCustom.display(dojo.body());
      }

      rally.addOnLoad(onLoad);
    </script>
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

    HTML_DEBUG_SDK1_TPL = <<-END
HTML_SDK1_BLOCK
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

    HTML_SDK1_TPL = <<-END
HTML_SDK1_BLOCK
    END

    CONFIG_TPL = <<-END
{
    "name": "APP_READABLE_NAME",
    "className": "CustomApp",
    "server": "APP_SERVER",
    "sdk": "APP_SDK_VERSION",
    "javascript": [
        DEFAULT_APP_JS_FILE
    ],
    "css": [
        DEFAULT_APP_CSS_FILE
    ]
}
    END

    DEPLOY_TPL = <<-END
{
    "server": "APP_SERVER",
    "username": "you@domain.com",
    "password": "S3cr3t",
    "project": "YourProject"
}
    END

    CSS_TPL = <<-END
.app {
     /* Add app styles here */
}
    END

    CSS_SDK1_TPL = <<-END
/* Add app styles here */
    END

    GITIGNORE_TPL = <<-END
# Ignore login credentials
#{Rally::AppSdk::AppTemplateBuilder::DEPLOY_FILE}
# Ignore debug build version of App
#{Rally::AppSdk::AppTemplateBuilder::HTML_DEBUG}
# Ignore 'local' build version of App
#{Rally::AppSdk::AppTemplateBuilder::HTML_LOCAL}
#Ignore All hidden files.
.*
    END
  end
end

## Helpers
def get_config_from_file
  config_file = Rally::AppSdk::AppTemplateBuilder::CONFIG_FILE
  deploy_file = Rally::AppSdk::AppTemplateBuilder::DEPLOY_FILE
  Rally::AppSdk::AppConfig.from_config_file(config_file, deploy_file)
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

def set_https(uri)
  prefix = 'https://'
  if uri =~ /\/\//     # schema given; force ours
    uri.gsub!(/^.*\/\//, prefix)
  else                 # no schema given
    uri = prefix + uri
  end
  uri
end
