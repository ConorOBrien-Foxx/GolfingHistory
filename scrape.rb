# expects to be ran in the base of the repository
# updates all repositories and _gohilogs directory
require 'fileutils'

def make_directory(dir_name)
    unless File.directory? dir_name
        FileUtils.mkdir_p dir_name
        puts "Directory '#{dir_name}' created."
        true
    else
        false
    end
end

langs = File.read("langs.txt").lines.map(&:chomp).each_slice(2)

puts "Initializing folder structure..."
repo_directory = "copies"
make_directory repo_directory
log_directory = "_gohilogs"
make_directory File.join repo_directory, log_directory

new_directories = 0
langs.each { |name, repo|
    fixed_name = name.gsub("/", "-")
    new_made = make_directory File.join repo_directory, fixed_name
    new_directories += 1 if new_made
}

puts "#{new_directories} new director#{new_directories == 1 ? "y" : "ies"} made"

puts "Updating repository contents..."

Dir.chdir repo_directory
langs.each { |name, repo|
    fixed_name = name.gsub("/", "-")
    puts "== #{name} (#{fixed_name}) =="
    Dir.chdir fixed_name
    system("git", "clone", repo, ".")
    unless $?.exitstatus.zero?
        # we need to simply update it if we cannot clone
        system("git", "pull")
    end
    puts "Writing log file..."
    log_file_src = File.join("..", log_directory, "#{fixed_name}.txt")
    File.write log_file_src, name + "\n" + `git log`
    Dir.chdir ".."
}
