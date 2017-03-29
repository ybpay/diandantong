require 'action_dispatch/routing/inspector'

namespace :ddb do
  namespace :routes do
    task make_feature_rel: :environment do
      all_routes = Rails.application.routes.routes
      inspector = MyRoutesInspector.new(all_routes)
      MakeActionFeatureRel.new(inspector.routes_of('Ddt::Core::Engine')).perform
    end

    task engine_names: :environment do
      all_routes = Rails.application.routes.routes
      inspector = MyRoutesInspector.new(all_routes)
      puts inspector.engines.keys
    end
  end
end






class MakeActionFeatureRel



  def initialize(all_routes)
    @h = {}
    all_routes.each do |route|
      @h[route[:control_path]] ||= {actions: [], control_name: route[:control_name]}
      @h[route[:control_path]][:actions] << route[:action_name]
    end
  end

  def perform
    scoped_h = {other: []}
    debugged = false
    indent = '  ' * 4
    @h.each_pair do |control_path, control_desc|
      feature_name = "model_#{control_desc[:control_name].singularize}"
      control_msg  = "#{indent}##{control_path}##{control_desc[:actions].join('|')}"
      feature_rel  = "#{indent}#{control_desc[:control_name]}: {:all => :#{feature_name}},"
      match = scopes.detect{|reg, scope| control_path.match(reg) != nil}
      if match
        name = match[1]
        scoped_h[name] ||= []
        scoped_h[name]  << control_msg
        scoped_h[name]  << feature_rel
      else
        scoped_h[:other] << control_msg
        scoped_h[:other] << feature_rel
      end
    end
    scoped_h.each do |scope, rels|
      puts render(scope, rels.join("\n"))
      puts "\n\n"
    end
  end

  def scopes
    {
      /^ddt\/backend/ => :backend,
      /^ddt\/webpos/  => :webpos,
      /^ddt\/weixin/  => :weixin,
      /^ddt\/common_api/ => :common_api,
      /^ddt\/agentsys/ => :agentsys,
    }
  end

  def render(name, body)
    <<-METHOD
    def #{name}
      {
#{body}
      }
    end
    METHOD
  end
end




class MyRoutesInspector
  def initialize(routes)
    @engines = {}
    @routes = collect_routes(routes)
  end

  def engines
    @engines
  end

  def routes_of(engine_name)
    # route: {:name, :verb, :path, :reqs}
    # eg: {:name=>"attachment_file", :verb=>"DELETE", :path=>"/attachment_files/:id(.:format)", :reqs=>"ckeditor/attachment_files#destroy"}
    @engines[engine_name]
  end

  private

  def collect_routes(routes)
    all_route = routes.collect do |route|
      ActionDispatch::Routing::RouteWrapper.new(route)
    end.reject(&:internal?).collect do |route|
      collect_engine_routes(route)
      control_path, action_name = route.reqs.split('#')
      control_name = control_path.split('/').last

      { control_path: control_path,
        control_name: control_name,
        action_name: action_name }

      # { name: route.name,
      #   verb: route.verb,
      #   path: route.path,
      #   reqs: route.reqs }

    end
  end

  def collect_engine_routes(route)
    name = route.endpoint
    return unless route.engine?
    return if @engines[name]

    routes = route.rack_app.routes
    if routes.is_a?(ActionDispatch::Routing::RouteSet)
      @engines[name] = collect_routes(routes.routes)
    end
  end
end
