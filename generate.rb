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

def createImage(comb)
  # プログレスバー
  bar = TTY::ProgressBar.new("Generating [:bar]", total: (comb[:items_base].length + comb[:items_deco].length))
  base_image = MiniMagick::Image.open(comb[:items_base][0])
  comb[:items_base].drop(1).each do |item|
    base_image = stackImage(base_image, item)
    bar.advance(1)
  end
  comb[:items_deco].each do |item|
    base_image = stackImage(base_image, item)
    bar.advance(1)
  end
  return base_image
end

def getFileNames(items_category)
  if (DEBUG)
    puts "The #{items_category} list is the followings:"
  end
  items = []
  # Get file names for each dirs
  CONFIG['files'][items_category].each_with_index do |dir, i|
    files = Dir.entries("#{CONFIG['assets_path']}/#{dir}").select { |f| File.file? File.join("#{CONFIG['assets_path']}/#{dir}", f) }
    files = files.reject{|entry| entry.start_with?(/\./) }
    files = files.map{|file| "#{CONFIG['assets_path']}/#{dir}/#{file}"}
    if (DEBUG)
      puts "DIR: #{dir}"
      puts files
    end
    items[i] = files
  end
  return items
end

def generateItemJson(i, comb)
  tags = []
  # Generate tags
  comb[:items_base].each do |item|
    dirname = File.basename(File.split(item).first)
    key = File.extname(dirname)[1..-1]
    tags << {
      key: key,
      value: File.basename(File.basename(item), ".png")
    }
  end
  comb[:items_deco].each do |item|
    dirname = File.basename(File.split(item).first)
    key = File.extname(dirname)[1..-1]
    tags << {
      key: key,
      value: File.basename(File.basename(item), ".png")
    }
  end
  result = {
      id: "#{format("%06d", i)}",
      tags: tags
  }
  return result
end

def generateJsonFile(array)
  File.open("results.json","w") do |file|
    file.puts(JSON.generate(array))
  end
end

begin
  # Get config data
  if File.exists? (CONFIG_FILE_PATH)
    CONFIG = YAML.load_file(CONFIG_FILE_PATH)
  else
    return nil
  end
  # Get all file names
  items_base = getFileNames('items_base')
  items_deco = getFileNames('items_deco')
  # Create random combs
  combs = getRandCombs(makeCombs(items_base, items_deco))
  puts "#{combs.length <= CONFIG['max_result_num'] ? combs.length : CONFIG['max_result_num']} images will be generated..."
  # Generate images with tags
  jsons = []
  combs.each_with_index do |comb, i|
    if (i >= CONFIG['max_result_num'])
      break
    end
    new_path = "./results/#{ CONFIG['generated_filename']}#{format("%06d", i)}[#{format("%06d", i)}].png"
    # Generate json tags
    jsons << generateItemJson(i, comb)
    # Generate image
    image = createImage(comb)
    image.write(new_path)
    puts " SUCCESS #{new_path}"
  end
  # Generate JSON
  generateJsonFile(jsons)
  # Done!
  puts "All the #{combs.length <= CONFIG['max_result_num'] ? combs.length : CONFIG['max_result_num']} images are finally generated!"
rescue Interrupt
  puts 'Exited!'
end
