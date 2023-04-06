require 'infobar'
require 'fileutils'
require 'term/ansicolor'
require 'json'

module Betterdocs
  module Generator
    class Swagger
      include ::Betterdocs::Generator::ConfigShortcuts
      include Term::ANSIColor
      include FileUtils

      def initialize(only: nil)
        only and @only = Regexp.new(only)
      end

      def generate
        if dir = config.swagger_output_directory.full?
          generate_to dir
        else
          raise 'Specify an output_directory in your configuration!'
        end
      end

      def generate_to(dirname)
        map = { openapi: '3.0.2', paths: {}, components: { schemas: {} } }
        add_error_envelope_schema(map[:components][:schemas])
        configure_for_creation
        prepare_dir(dirname)
        add_global_info(map)
        create_sections(map)
        create_swagger(map, dirname)
        create_assets
        self
      end

      def configure_for_creation
        infobar.puts color(40, "Setting asset_host to #{Betterdocs::Global.asset_host.inspect}.")
        Betterdocs.rails.configuration.action_controller.asset_host = Betterdocs::Global.asset_host
        options = {
          host: Betterdocs::Global.api_host,
          protocol: Betterdocs::Global.api_protocol
        }
        infobar.puts color(40, "Setting default_url_options to #{options.inspect}.")
        Betterdocs.rails.application.routes.default_url_options = options
        self
      end

      def add_global_info(map)
        slugs = get_request_url_slugs(sections.values.first.first.request)
        map[:info] = { title: project_name, version: slugs[:ver] }
        map[:servers] =
          [{ url: "#{slugs[:protocol]}://#{[slugs[:host], slugs[:lang], "api_#{slugs[:ver]}"].join('/')}" }]
      end

      def create_sections(map)
        Infobar(total: sections.size)
        sections.values.each do |section|
          infobar.progress(
            message: " Section #{section.name.to_s.inspect} %c/%t in %te ETA %e @%E ",
            force: true
          )
          @only =~ section.name or next if @only

          map = get_section_data(map, section)
        end
        infobar.finish message: ' %t sections created in %te, completed @%E '
        infobar.newline
        self
      end

      def create_assets
        Infobar(total: config.swagger_assets.size)
        config.each_swagger_asset do |src, dst|
          infobar.progress(
            message: " Asset #{File.basename(src).inspect} %c/%t in %te ETA %e @%E ",
            force: true
          )
          mkdir_p File.dirname(dst)
          cp Betterdocs.rails.root.join(src), dst
        end
        infobar.finish message: ' %t assets created in %te, completed @%E '
        infobar.newline
        self
      end

      def create_swagger(map, dirname)
        name = 'swagger.json'
        cd dirname do
          infobar.puts color(40, 'Creating swagger.')
          json = JSON.pretty_generate(map)
          render_to(name, json)
        end
        self
      end

      def fail_while_rendering(exception)
        message = color(
          231,
          on_color(124, " *** ERROR #{exception.class}: #{exception.message.inspect} ***")
        )
        infobar.puts message
        exit 1
      end

      def add_param(hash, name, param_in, required = false, type = nil, description = '', schema = nil)
        hash[:parameters] ||= []
        p = { in: param_in, required: required, description: description, name: name }
        p[:schema] = { type: type } unless type.nil?
        p[:schema] = schema unless schema.nil?
        hash[:parameters].push(p)
        hash
      end

      def add_default_list_params(hash)
        p = add_param(hash, 'page', 'query', false, 'integer')
        add_param(p, 'per_page', 'query', false, 'integer')
      end

      def get_list_response_wrapper_schema
        {
          type: 'object',
          properties: {
            total_entries: { type: 'integer' },
            offset: { type: 'integer' },
            total_pages: { type: 'integer' },
            current_page: { type: 'integer' },
            per_page: { type: 'integer' }
          },
          required: %w[total_entries offset current_page per_page total_pages data]
        }
      end

      def get_param_value_type(value)
        case value
        when String then 'string'
        when Integer then 'integer'
        when TrueClass, FalseClass then 'boolean'
        when Float then 'number'
        when Array then 'array'
        else 'object'
        end
      end

      def get_path_param_slug_type(slug)
        return 'integer' if /\A[0-9]+\z/.match(slug)

        'string'
      end

      def add_error_envelope_schema(definitions)
        definitions['ErrorEnvelope'] = {
          type: 'object',
          properties: {
            name: { type: 'string' },
            status: { type: 'string' },
            status_code: { type: 'integer' },
            reason: { type: 'string' },
            backtrace: { type: 'array', items: { type: 'string' } },
            message: { type: 'string' },
            errors: { type: 'object' },
            links: { type: 'array', items: { type: 'string' } }
          },
          required: %w[name status status_code reason backtrace message links]
        }
      end

      def get_error_envelope_schema_ref
        { schema: get_schema_ref('ErrorEnvelope') }
      end

      def get_request_url_slugs(request)
        slugs = %r{
          (?<method>GET|POST|PUT|DELETE|OPTIONS)\s+
          (?<protocol>https?)://
          (?<host>[a-z.]+)/
          (?<lang>[a-z]{2})/api_
          (?<ver>v[0-9]+)/
          (?<path>[\w/-]+\.json?)
        }x.match(request).named_captures.transform_keys(&:to_sym)
        slugs[:params] = []
        split = slugs[:path].split('/')
        path_cmp = split.map.with_index do |cmp, i|
          unless i.even?
            suffix = cmp['.json'] || ''
            name = "#{split[i - 1]}_id"
            cmp = "{#{name}}#{suffix}"
            param = { name: name, type: get_path_param_slug_type(cmp.gsub('.json', '')) }
            slugs[:params].push(param)
          end
          cmp
        end
        slugs[:method] = slugs[:method].downcase
        slugs[:path] = "/#{path_cmp.join('/')}"
        slugs
      end

      def get_request_definition(params)
        schema = { type: 'object', properties: {}, required: [] }
        params.each do |param|
          schema[:properties][param.name] = get_schema(param.types, nil, param.description, nil)
          schema[:required].push(param.name) if param.required == true || param.required == 'yes'
        end
        schema
      end

      def get_name(title)
        /([\w\s]+)/.match(title)[1]
      end

      def get_type(types)
        type = types
        nullable = false
        if types.instance_of? Array
          case types.length
          when 0
            type = nil
          when 1
            type = types[0]
          else
            types.each do |t|
              if t == 'null'
                nullable = true
              else
                type = t
              end
            end
          end
        end
        unless %w[integer number string boolean array object].include?(type)
          puts "Warning: invalid type #{type || 'nil'}"
        end
        [type, nullable]
      end

      def get_deprecated_from_description(description)
        description.include?('DEPRECATED')
      end

      def get_schema(types, sub_cls, description, optional)
        type, nullable = get_type(types)
        deprecated = get_deprecated_from_description(description)
        res = { description: description, type: type, nullable: nullable, deprecated: deprecated, optional: optional }
        case type
        when 'array'
          items = { type: 'string' }
          items = get_schema_ref(sub_cls) if sub_cls
          res[:items] = items
        when 'object'
          res = get_schema_ref(sub_cls) if sub_cls
          res[:description] = description
          res[:deprecated] = deprecated
        end
        res[:nullable] = true if nullable
        res
      end

      def get_dto_name(representer)
        representer&.name&.demodulize
      end

      def add_links_definition(definitions, cls, value)
        definition = initialise_definition(definitions, cls)
        definition[:properties][:links] ||= {
          type: 'array',
          nullable: false,
          items: {
            type: 'object',
            properties: {
              rel: { type: 'string', enum: [] },
              href: { type: 'string' },
              templated: { type: 'boolean' }
            },
            required: %w[rel href]
          }
        }
        enum = definition[:properties][:links][:items][:properties][:rel][:enum]
        enum.push(value) unless enum.include?(value)
      end

      def initialise_definition(definitions, cls)
        definitions[cls] ||= { type: 'object', properties: {} }
      end

      def add_response_schema(definitions, response)
        return nil unless response.full?

        subs = {}
        resp_cls = get_dto_name(response.representer)
        (response.full?(:properties) || []).each do |p|
          subs[p.full_name] = p.sub_representer? if p.sub_representer?
          sub_cls = get_dto_name(subs[p.nesting_name])
          cls = sub_cls || resp_cls
          definition = initialise_definition(definitions, cls)
          definition[:properties][p.public_name] =
            get_schema(p.types, get_dto_name(p.sub_representer?), p.description, p.optional)
        end
        (response.full?(:links) || []).each do |l|
          sub_cls = get_dto_name(subs[l.nesting_name])
          add_links_definition(definitions, sub_cls || resp_cls, l.public_name)
        end
        get_schema_ref(resp_cls)
      end

      def get_schema_ref(name)
        {
          "$ref": "#/components/schemas/#{name}"
        }
      end

      def add_required_to_definitions(definitions)
        definitions.each do |def_key, d|
          req = d[:properties].select { |_k, v| v.key?(:nullable) && !v[:optional] }.keys
          d[:properties].each do |p|
            p.delete(:optional)
          end
          definitions[def_key][:required] = req unless req.empty?
        end
      end

      def add_body(definitions, params, action, name)
        if action.json_params.full?
          payload_name = "#{name.titleize.gsub(/\s/, '')}Request"
          definitions[payload_name] = get_request_definition(action.json_params.values)
          params[:requestBody] = wrap_content_object({ schema: get_schema_ref(payload_name) }, "#{name} Request")
        end
      end

      def add_path_params(params, from_path)
        from_path.each do |param|
          add_param(params, param[:name], 'path', true, param[:type], param[:name])
        end
      end

      def add_query_params(params, from_query, is_a_list)
        from_query.each do |param|
          add_param(params, param.name, 'query', param.required, get_param_value_type(param.value),
                    param.description)
        end
        add_default_list_params(params) if is_a_list
      end

      def wrap_content_object(object, description)
        { content: { "application/json": object }, description: description }
      end

      def add_example(obj, name, example)
        obj[:examples] ||= {}
        obj[:examples][name] = { value: example }
      end

      def get_section_data(map, section)
        section.each do |action|
          name = get_name(action.title)
          p = { description: action.description, summary: name }
          is_a_list = action.response.data.instance_of?(ApiTools::ResultSet)
          slugs = get_request_url_slugs(action.request)
          add_path_params(p, slugs[:params])
          add_query_params(p, action.params.values, is_a_list)
          add_body(map[:components][:schemas], p, action, name)
          item = add_response_schema(map[:components][:schemas], action.response)
          schema = item
          if is_a_list
            list = get_list_response_wrapper_schema
            list[:properties][:data] = { type: 'array', items: item }
            schema = list
          end
          ok = { schema: schema }
          unless action.response.nil?
            add_example(ok, 'example', JSON.parse(JSON.pretty_generate(action.response.to_json, quirks_mode: true)))
          end
          p[:responses] =
            { "200": wrap_content_object(ok, 'OK'),
              default: wrap_content_object(get_error_envelope_schema_ref, 'Error') }
          wrapped = {}
          wrapped = map[slugs[:path]] if map.key?(slugs[:path])
          wrapped[slugs[:method]] = p
          map[:paths][slugs[:path]] = wrapped
        end
        add_required_to_definitions(map[:components][:schemas])
        map
      end

      def render_to(filename, content)
        File.open(filename, 'w') do |output|
          output.write(content)
        end
        self
      rescue StandardError => e
        fail_while_rendering(e)
      end

      def prepare_dir(dirname)
        dirname.present? or raise ArgumentError,
                                  "#{dirname.inspect} should be an explicite output dirname"
        begin
          stat = File.stat(dirname)
          if stat.directory?
            rm_rf Dir[dirname.to_s + '/**/*']
          else
            raise ArgumentError, "#{dirname.inspect} is not a directory"
          end
        rescue Errno::ENOENT
        end
        mkdir_p dirname.to_s
        self
      end
    end
  end
end
