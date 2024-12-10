# frozen_string_literal: true

require "rake/tasklib"
require_relative "make"

module RubyCore
  class ExtensionTask < Rake::TaskLib
    attr_reader :libs

    def initialize(gemspec, build_base: ENV.fetch("BUILD_DIR", ".build"))
      super()

      if gemspec.extensions.empty?
        warn "No extensions in #{gemspec.loaded_from}"
        return
      end
      @gemspec = gemspec
      @build_base = build_base
      define
    end

    def define
      task "compile"
      task ".force"
      extlibs = @gemspec.extensions.map {|extconf| define_extconf_task(extconf)}
      @libs = extlibs
      extlibs.each {|build_dir| define_loader_task(build_dir)}
      # replace_test_libs(extlibs)
    end

    def define_extconf_task(extconf)
      extension_dir = File.dirname(extconf)

      # Extract extension name passed to `create_makefile`.
      # Do not use %-literals other than simple quotes.
      extension_name = File.read(extconf)[/create_makefile\(? *(['"])(.*?)\1/, 2]

      build_dir = File.join(@build_base, RUBY_VERSION, RUBY_PLATFORM)
      extlib = build_dir
      build_dir = "#{build_dir}/#{File.dirname(extension_name)}" if extension_name.include?("/")

      desc("The build directory for #{extension_name}")
      directory build_dir

      makefile = "#{build_dir}/Makefile"
      desc("Makefile in #{build_dir}")
      file makefile => "#{extension_dir}/depend" if File.exist?("#{extension_dir}/depend")
      file(makefile => extconf) {
        ruby("-C", build_dir, Pathname(extconf).relative_path_from(Pathname(build_dir)).to_s)
      } | build_dir

      so = "#{build_dir}/#{extension_name}.#{RbConfig::CONFIG['DLEXT']}"
      desc("Extension library: #{so}")
      file(so => [:".force", makefile]) {MAKE[chdir: build_dir]}

      task :compile => so

      extlib
    end

    def replace_test_libs(extlibs)
      # HACK: Replace `:extlibs` in `libs` of tasks defined by
      # `Rake::TestTask.new("test")` with the built extension directories.
      Rake::Task["test"]&.actions&.each do |act|
        if (Rake::TestTask === (task = act.binding.receiver) and
            at = task.libs.find_index(:extlibs))
          task.libs[at, 1] = extlibs
        end
      end
    end

    def define_clean_tasks(build_dir)
      clean = ":clean:#{build_dir}"
      distclean = ":distclean:#{build_dir}"
      task clean do
        if File.exist?("#{build_dir}/Makefile")
          MAKE["clean", chdir: build_dir]
        end
      end
      task :clean => clean
      task distclean do
        if File.exist?("#{build_dir}/Makefile")
          MAKE["distclean", chdir: build_dir]
        end
        if File.directory?(build_dir)
          FileUtils.rmdir(build_dir, parents: true, verbose: true)
        end
      end
      task :distclean => distclean
      task clobber: :distclean
    end

    def define_loader_task(build_dir)
      define_clean_tasks(build_dir)
      loader = "#{build_dir}/run.rb"
      file(loader) {|task| create_loader(task.name)} | build_dir
    end

    def create_loader(loader)
      File.write(loader, "$:.unshift File.join(__dir__, RUBY_VERSION, RUBY_PLATFORM)")
    end
  end
end
