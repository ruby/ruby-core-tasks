# frozen_string_literal: true

require "bundler/gem_tasks"

helper = Bundler::GemHelper.instance

desc "Set SOURCE_DATE_EPOCH environment variable to the latest commit for stable build"
task "date_epoch" do
  path = helper.gemspec.loaded_from
  epoch = IO.popen(%W[git log -1 --no-show-signature --format=%ct], chdir: File.dirname(path), &:read).chomp
  ENV["SOURCE_DATE_EPOCH"] = epoch
end

task "build" => "date_epoch"
