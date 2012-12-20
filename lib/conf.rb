require 'yaml'

Conf = YAML.load(File.read("lib/conf.yml"))

def Conf.save
    File.open("lib/conf.yml", "w") do |file|
        file.puts YAML.dump Conf
    end
end

def Conf.reset
    self[:winning_score] = 3
    self[:ball_speed] = 5
    self[:music] = true
    self[:fx] = true
end