require 'rake/testtask'
require 'rails/test_unit/sub_test_task'
namespace :test do
  Rails::TestTask.new(:s) do |t|
    param = ARGV[1]
    if param.present? && File.file?(param) && param.end_with?("_test.rb")
      t.pattern = param
    elsif param.present? && File.directory?(param)
      t.pattern = "#{param}**/*_test.rb"
    else
      t.pattern = "test/**/*_test.rb"
    end
  end
end