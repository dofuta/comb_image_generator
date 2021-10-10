# Require all gems
require 'bundler'
Bundler.require

# Config file path
CONFIG_FILE_PATH = "./config.yml"
DEBUG = false

def makeCombs(items_base, items_deco)
  combs = {
    items_base: items_base[0].product(*(items_base.drop(1))),
    items_deco: items_deco[0].product(*(items_deco.drop(1)))
  }
  return combs
end

def getRandCombs(combs)
  results = []
  combs_deco_len = combs[:items_deco].length
  combs[:items_base].each do |comb|
    result = {
      items_base: comb,
      items_deco: combs[:items_deco][rand(combs_deco_len)]
    }
    results.push(result)
  end
  results.shuffle!
  return results
end

def stackImage(base_image, file_name)
  result = base_image.composite(MiniMagick::Image.open(file_name)) do |config|
    config.compose 'Over'
    config.gravity 'NorthWest'
    config.geometry '+0+0'
  end
  return result
end

def createImage(combs)

  # プログレスバー
  bar = TTY::ProgressBar.new("Generating [:bar]", total: (combs[:items_base].length + combs[:items_deco].length))
  base_image = MiniMagick::Image.open(combs[:items_base][0])
  combs[:items_base].drop(1).each do |item|
    base_image = stackImage(base_image, item)
    bar.advance(1)
  end
  combs[:items_deco].each do |item|
    base_image = stackImage(base_image, item)
    bar.advance(1)
  end
  return base_image
end


# Get YAML data
if File.exists? (CONFIG_FILE_PATH)
  CONFIG          = YAML.load_file(CONFIG_FILE_PATH)
else
  return nil
end

if (DEBUG)
  puts "The base item list is the followings:"
end
items_base = []
# Get file names for each dirs
CONFIG['files']['items_base'].each_with_index do |dir, i|
  files = Dir.entries("#{CONFIG['assets_path']}/#{dir}").select { |f| File.file? File.join("#{CONFIG['assets_path']}/#{dir}", f) }
  files = files.reject{|entry| entry.start_with?(/\./) }
  files = files.map{|file| "#{CONFIG['assets_path']}/#{dir}/#{file}"}
  if (DEBUG)
    puts "DIR: #{dir}"
    puts files
  end
  items_base[i] = files
end

if (DEBUG)
  puts "The deco item list is the followings:"
end
items_deco = []
CONFIG['files']['items_deco'].each_with_index do |dir, i|
  files = Dir.entries("#{CONFIG['assets_path']}/#{dir}").select { |f| File.file? File.join("#{CONFIG['assets_path']}/#{dir}", f) }
  files = files.reject{|entry| entry.start_with?(/\./) }
  files = files.map{|file| "#{CONFIG['assets_path']}/#{dir}/#{file}"}
  if (DEBUG)
    puts "DIR: #{dir}"
    puts files
  end
  items_deco[i] = files
end

# Create random combs
combs = getRandCombs(makeCombs(items_base, items_deco))

puts "#{combs.length} images will be generated...."

# Generate images
combs.each_with_index do |comb, i|
  if (i > CONFIG['max_result_num'])
    break
  end
  new_path = "./results/#{i}.png"
  image = createImage(comb)
  image.write(new_path)
  puts " SUCCESS #{new_path}"
end

puts "All the #{combs.length} images are finally generated!"
