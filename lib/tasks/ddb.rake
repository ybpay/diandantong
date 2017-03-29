task :stats => "ddb:statsetup"

namespace :ddb do
  task :statsetup do
    require 'rails/code_statistics'
    %w(_agentsys _api _backend _core _weixin _webpos).each do |ename|
      {
        "/a/c" => "/app/controllers",
        "/a/h" => "/app/helpers",
        "/a/m" => "/app/models",
        "/a/js" => "/app/assets/javascripts",
        "/lib" => "/lib",
      }.each do |sname, fname|
        ::STATS_DIRECTORIES << ["#{ename}#{sname}" , "#{ename}#{fname}"] if Dir.exists?("#{ename}#{fname}")
      end
    end
  end


end
