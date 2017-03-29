#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'json'
require 'pp'
require 'tempfile'
require 'set'

program :name, 'Heap Analyzer'
program :version, '0.0.1'
program :description, 'Heap Analyzer'

$TMPDIR = '/tmp'
global_option('--tmpdir TMPDIR', 'assign Temporary directory, should be as short as possible') {|tmpdir| $TMPDIR = tmpdir}
global_option('--verbose', 'print verbose infomation') {|verbose| $VERBOSE = true}

def verbose(message = nil)
  if $VERBOSE
    message = yield if block_given?
    message.each_line do |line|
      puts "[VERBOSE] #{line}"
    end
  end
end

module HeapAnalyzerHelper
  class << self

    def rails_pids(file = "#{File.dirname($0)}/../tmp/pids/unicorn.pid")
      unless File.exists?(file)
        file = "#{File.dirname(file)}/server.pid"
      end
      if File.exists?(file)
        ppid = `cat #{file}`
        if File.basename(file) == 'unicorn'
          pids = `pgrep -P #{ppid}`.split(/\\s+/)
          [ppid].concat(pids)
        else
          [ppid]
        end
      else
        []
      end
    end

    def eval_script(pid, script, options = {})
      if script.length > 25
        unless File.directory?($TMPDIR) and File.writable?($TMPDIR)
          raise "temporary directory #$TMPDIR is not writable"
        end
        script_file_path = "#$TMPDIR/ha_sr_#{rand(1000)}.rb"
        verbose {"writing script to #{script_file_path}:\n#{script}"}
        script_file = open(script_file_path, 'w')
        script_file.write(script)
        script_file.close
        verbose {
          write_success = open(script_file_path).read == script
          if write_success
            "written script to #{script_file_path}"
          else
            "failed to write script to #{script_file_path}"
          end
        }
        cmd = "rbtrace -p #{pid} --timeout=#{options[:timeout] || 10} -e 'load \"#{script_file_path}\"'"
        verbose {"Invoke command: #{cmd}"}
        system(cmd)
        File.delete(script_file_path)
      else
        cmd = "rbtrace -p #{pid} --timeout=#{options[:timeout] || 10} -e '#{script}'"
        verbose {"Invoke command: #{cmd}"}
        system(cmd)
      end
    end

    def generate_classes_summary(file)
      classes = {}
      open(file).each_line do |line|
        e = JSON.parse(line)
        case e['type']
          when 'CLASS', 'MODULE'
            name = e['name']
            classes[name] = {
                count: 0,
                memsize: 0,
                nrefs: 0,
                olds: 0
            } if classes[name] == nil

            classes[name][:count] += 1
            classes[name][:memsize] += e['memsize']
            classes[name][:nrefs] += e['references'].count
            classes[name][:olds] += 1 if e['flags'] and e['flags']['old'] == true
        end
      end
      classes
    end

  end
end

##===============================================================
## guess rails pid
##===============================================================
command :pid do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options]"
  c.summary = 'guess rails\' server pid'
  c.description = 'guess rails\' server pid'
  c.example 'print pid', "#$PROGRAM_NAME #{c.name}"
  c.option '-f', '--file FILE', String, 'pid file'
  c.action do |args, options|
    options.default file: "#{File.dirname($0)}/../tmp/pids/unicorn.pid", pid: HeapAnalyzerHelper.rails_pids.last
    puts HeapAnalyzerHelper.rails_pids(options.file)
  end
end

##===============================================================
## dump heap
##===============================================================

command :dump do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options]"
  c.summary = 'dump heap of process'
  c.description = 'dump heap of process'
  c.example 'dump heap of process PID and write to OUTFILE', "#$PROGRAM_NAME #{c.name} -p PID -o OUTFILE"
  c.option '-p', '--pid PID', Integer, 'process id'
  c.option '-o', '--output-file OUTFILE', String, 'output file'
  c.option '-g', '--gc', 'make a gc before dump'
  c.action do |args, options|
    options.default pid: HeapAnalyzerHelper.rails_pids.last
    outfile = options.output_file
    # 路径要足够短
    script = <<SCRIPT
require "objspace";
ObjectSpace.trace_object_allocations_start;
GC.start() if #{options.gc == true};
if #{outfile != nil}
  out = File.open("#{outfile}", "w");
  ObjectSpace.dump_all(output: out);
  out.close;
else
  out = STDOUT
  ObjectSpace.dump_all(output: out);
end
SCRIPT
    HeapAnalyzerHelper.eval_script(options.pid, script)
  end
end

##===============================================================
## print gc statistics
##===============================================================

command :stat do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options]"
  c.summary = 'print gc statistics of process'
  c.description = 'print gc statistics of process'
  c.example 'print gc statistics', "#$PROGRAM_NAME #{c.name} -p PID"
  c.option '-p', '--pid PID', Integer, 'process id'
  c.action do |args, options|
    options.default pid: HeapAnalyzerHelper.rails_pids.last
    HeapAnalyzerHelper.eval_script(options.pid, 'GC.stat')
  end
end

##===============================================================
## force minor gc
##===============================================================

command :gc do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options]"
  c.summary = 'force garbage collection'
  c.description = 'force garbage collection'
  c.example 'force major gc', "#$PROGRAM_NAME #{c.name} -p PID"
  c.example 'force minor gc', "#$PROGRAM_NAME #{c.name} -np PID"
  c.option '-p', '--pid PID', Integer, 'process id'
  c.option '-n', '--minor', 'minor gc'
  c.option '-i', '--immediate', 'immediate sweep'
  c.action do |args, options|
    options.default :immediate => true, :minor => false, pid: HeapAnalyzerHelper.rails_pids.last
    HeapAnalyzerHelper.eval_script(options.pid, "GC.start(full_mark: #{options.minor == false}, immediate_sweep: #{options.immediate == true})")
  end
end

##===============================================================
## inject scrpit
##===============================================================

command :eval do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options] script"
  c.summary = 'eval script in context of given process'
  c.description = 'eval script in context of given process'
  c.example 'eval script', "#$PROGRAM_NAME #{c.name} -p PID 'GC.stat'"
  c.option '-p', '--pid PID', Integer, 'process id'
  c.option '-f', '--script-file FILE', String, 'script file to inject'
  c.action do |args, options|
    options.default pid: HeapAnalyzerHelper.rails_pids.last
    HeapAnalyzerHelper.eval_script(options.pid, args[0]) if args.length > 0
    if options.script_file
      f = open(options.script_file)
      script = f.read
      f.close
      HeapAnalyzerHelper.eval_script(options.pid, script)
    end
  end
end

##===============================================================
## heap size analyzer
##===============================================================

command :size do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options] file"
  c.summary = 'print heap size summary'
  c.description = 'print heap size summary'
  c.example 'print heap size information', "#$PROGRAM_NAME #{c.name} heap.json"
  c.action do |args, options|
    stats = {}
    open(args[0]).each_line do |line|
      e = JSON.parse(line)
      type = e['type']

      stats[type] = {
          count: 0,
          type: type,
          olds: 0
      } if stats[type] == nil

      # pp e

      case type
        when 'STRING'
          bytesize = e['bytesize']
        when 'CLASS','MODULE'
          memsize = e['memsize']
          nrefs = e['references'].count
        when 'ARRAY'
          size = e['length']
          nrefs = (e['references'] || []).count
        when 'HASH'
          size = e['size']
          memsize = e['memsize']
          nrefs = (e['references'] || []).count
        when 'DATA'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'REGEXP'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'STRUCT'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'RATIONAL', 'FLOAT', 'BIGNUM', 'COMPLEX'
          ;
        when 'MATCH'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'FILE'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'OBJECT'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'NODE'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'ICLASS'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        when 'ROOT'
          memsize = e['memsize'] || 0
          nrefs = (e['references'] || []).count
        else
          pp e
      end

      stats[type][:count] += 1
      stats[type][:olds] += 1 if e['flags'] and e['flags']['old'] == true
      stats[type][:memsize] = (stats[type][:memsize] || 0) + (memsize || 0) if memsize != nil
      stats[type][:bytesize] = (stats[type][:bytesize] || 0) + (bytesize || 0) if bytesize != nil
      stats[type][:size] = (stats[type][:size] || 0) + (size || 0) if size != nil
      stats[type][:nrefs] = (stats[type][:nrefs] || 0) + (nrefs || 0) if nrefs != nil
    end

    all = {
        count: 0,
        olds: 0,
        memsize: 0,
        bytesize: 0,
        size: 0,
        nrefs: 0,
    }

    stats.each do |k,v|
      %w(count olds memsize bytesize size nrefs).each do |col|
        all[col.to_sym] += v[col.to_sym] if v[col.to_sym]
      end
    end
    stats['ALL'] = all

    pp stats
  end
end


##===============================================================
## generation analyzer
##===============================================================

class GenerationAnalyzer
  def initialize(filename, generation = nil)
    @filename = filename
    @generation = generation
  end

  def analyze
    data = []
    unless @generation
      File.open(@filename) do |f|
        f.each_line do |line|
          parsed=JSON.parse(line)
          data << parsed
        end
      end

      data.group_by{|row| row['generation']}
          .sort{|a,b| a[0].to_i <=> b[0].to_i}
          .each do |k,v|
        puts "generation #{k} objects #{v.count}"
      end
    else
      File.open(@filename) do |f|
        f.each_line do |line|
          parsed=JSON.parse(line)
          data << parsed if parsed['generation'] == @generation
        end
      end

      data.group_by{|row| "#{row['file']}:#{row['line']}"}
          .sort{|a,b| b[1].count <=> a[1].count}
          .each do |k,v|
        puts "#{k} * #{v.count}"
      end

    end
  end
end

command :generation do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options] file"
  c.summary = 'print generation summary'
  c.description = 'print generation summary'
  c.example 'print generation summary', "#$PROGRAM_NAME #{c.name} heap.json"
  c.example 'print specific generation information', "#$PROGRAM_NAME #{c.name} -g 80 heap.json"
  c.option '-g', '--generation GENERATION_ID', Integer, 'generation id'
  c.action do |args, options|
    options.default :generation => nil
    GenerationAnalyzer.new(args[0], options.generation).analyze
  end
end

##===============================================================
## classes analyzer
##===============================================================

command :classes do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options] file"
  c.summary = 'print classes summary'
  c.description = 'print classes summary'
  c.example 'print classes summary, sort by references count', "#$PROGRAM_NAME #{c.name} -s nrefs heap.json"
  c.option '-s', '--sort-by COLUMN', String, 'sort by column'
  c.action do |args, options|
    options.default :sort_by => :memsize
    pp HeapAnalyzerHelper.generate_classes_summary(args[0]).sort_by{|k,v|v[options.sort_by.to_sym]}
  end
end

##===============================================================
## classes differ
##===============================================================

# command :diff do |c|
#   c.syntax = 'heap_analyzer diff [options]'
#   c.summary = ''
#   c.description = ''
#   c.example 'description', 'heap_analyzer diff_classes -p pattern -s memsize heap1 heap2'
#   c.option '-s', '--sort-by COLUMN', String, 'sort by column'
#   c.option '-p', '--name-pattern PATTERN', String, 'name pattern regex, ruby syntax'
#   c.action do |args, options|
#     # Do something or c.when_called Heap_analyzer::Commands::Count
#     options.default :sort_by => :memsize
#     classes1 = HeapAnalyzerHelper.generate_classes_summary(args[0])
#     classes2 = HeapAnalyzerHelper.generate_classes_summary(args[1])
#     diff = {}
#     classes2.each do |name,s2|
#       s1 = classes1[name]
#       if s1 == nil
#         diff[name] = s2
#       else
#         diff[name] = {}
#         s2.each {|k,v| diff[name][k] = v - s1[k]}
#         diff.delete(name) if diff[name].all? {|k,v| v == 0}
#         classes1.delete(name)
#       end
#     end
#     classes1.each do |name, s1|
#       diff[name] = {}
#       s1.each {|k,v| diff[name][k] = -s1[k]}
#     end
#     if options.name_pattern
#       diff = diff.select{|k,v| k =~ Regexp.new(options.name_pattern)}
#     end
#     pp diff.sort_by{|k,v|v[options.sort_by.to_sym]}
#   end
# end

##===============================================================
## leak finder
##===============================================================

command :leak do |c|
  c.syntax = "ruby #$PROGRAM_NAME #{c.name} [options] file1 file2 file3"
  c.summary = 'find possible leak'
  c.description = 'find possible leak'
  c.example 'find possible leak', "#$PROGRAM_NAME #{c.name} heap1.json heap2.json heap3.json"
  c.action do |args, options|

    # idea from: http://blog.skylight.io/hunting-for-leaks-in-ruby/

    if args.length != 3
      puts "Usage: #{c.syntax}"
      return 1
    end

    first_addrs = Set.new
    third_addrs = Set.new

    # Get a list of memory addresses from the first dump
    File.open(args[0], 'r').each_line do |line|
      parsed = JSON.parse(line)
      first_addrs << parsed['address'] if parsed && parsed['address']
    end

    # Get a list of memory addresses from the last dump
    File.open(args[2], 'r').each_line do |line|
      parsed = JSON.parse(line)
      third_addrs << parsed['address'] if parsed && parsed['address']
    end

    diff = []

    # Get a list of all items present in both the second and
    # third dumps but not in the first.
    File.open(args[1], 'r').each_line do |line|
      parsed = JSON.parse(line)
      if parsed && parsed['address']
        if !first_addrs.include?(parsed['address']) && third_addrs.include?(parsed['address'])
          diff << parsed
        end
      end
    end

    # Group items
    diff.group_by do |x|
      [x['type'], x['file'], x['line']]
    end.map do |x, y|
      # Collect memory size
      [x, y.count, y.inject(0) { |sum, i| sum + (i['bytesize'] || 0) }, y.inject(0) { |sum, i| sum + (i['memsize'] || 0) }]
    end.sort do |a, b|
      b[1] <=> a[1]
    end.each do |x, y, bytesize, memsize|
      # Output information about each potential leak
      puts "Leaked #{y} #{x[0]} objects of size #{bytesize}/#{memsize} at: #{x[1]}:#{x[2]}"
    end

    # Also output total memory usage, because why not?
    memsize = diff.inject(0) { |sum, i| sum + (i['memsize'] || 0) }
    bytesize = diff.inject(0) { |sum, i| sum + (i['bytesize'] || 0) }
    puts "\n\nTotal Size: #{bytesize}/#{memsize}"
  end
end

