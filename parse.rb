# expects to be ran in the base of the repository
# expects scrape.rb to have ran, and updated repositories + _gohilogs directory
require 'date'
require 'json'
require 'set'

language_data = {}
min_year = max_year = nil
Dir[File.join("copies", "_gohilogs", "*.txt")].each { |file|
    language_name = File.basename file, ".txt"
    commit_points = File.read(file)
        .scan(/commit.+\nAuthor:.+\nDate:\s+(.+)(?:\n|$)/)
        .map { Date.parse _1.first }
    
    language_data[language_name] = {
        commit_points: commit_points
    }
    
    min_year = [min_year, commit_points.min.year].compact.min
    max_year = [max_year, commit_points.max.year].compact.max
}

# per year, per month
output_data = {}
(min_year..max_year).each { |year|
    output_data[year] = {}
    (1..12).each { |month|
        output_data[year][month] = {}
    }
}

language_data.each { |name, data|
    commit_points = data[:commit_points]
    commit_points.each { |date|
        # p [name, date.year, date.month]
        output_data[date.year][date.month][name] ||= 0
        output_data[date.year][date.month][name] += 1
    }
}

language_names = language_data.keys
File.write "results.json", {
    "languages" => language_names,
    "commits" => output_data
}.to_json
