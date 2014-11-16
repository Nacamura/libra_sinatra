require 'json'

class MyJSON
  def self.load_json(textfile_path)
    open(textfile_path) do |io|
      JSON.load(io)
    end
  end

  def self.store_json(array, textfile_path)
    open(textfile_path, "w") do |io|
      JSON.dump(array, io)
    end
  end
end

