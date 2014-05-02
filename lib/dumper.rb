require "digest/md5"

class Dumper
	def initialize options
		@options = options
		@dumps = []
	end

	def generateId

	end

	def getDumpDir
		return File.realpath(File.dirname(__FILE__)+'/../dumps')
	end

	def getDumpCommand filename
		password = @options[:password].to_s != '' ? "-p#{@options[:password]}" : ""
		return "mysqldump -u#{@options[:user]} #{password} #{@options[:database]} > #{getDumpDir}/#{filename}"
	end

	def getLoadCommand filename
		password = @options[:password].to_s != '' ? "-p#{@options[:password]}" : ""
		return "mysql -u#{@options[:user]} #{password} #{@options[:database]} < #{getDumpDir}/#{filename}"
	end

	def save
		filename = Digest::MD5.hexdigest(getDumpCommand(Time.now.to_f))
		cmd = getDumpCommand(filename)
		puts cmd
		`#{cmd}`
		@dumps << filename
	end

	def load
		filename = @dumps.pop
		cmd = getLoadCommand filename
		puts cmd
		`#{cmd}`
		`rm #{getDumpDir}/#{filename}`
	end
end