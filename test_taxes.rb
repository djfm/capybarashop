# encoding: UTF-8

require_relative 'lib/bricks.rb'
require_relative 'lib/dumper.rb'

require 'json'

# configuration

# READ ME CAREFULLY
# We prefer convention over configuration, so:
# - The shop must have its admin folder named 'admin-dev'
# - There must be a superadmin with login pub@prestashop.com/123456789
# - There must be a customer with login pub@prestashop.com/123456789

# Web root of the PrestaShop installation
Capybara.app_host = 'http://localhost/1.6'
# database settings
dumper = Dumper.new :user => 'root', :password => '', :database => '1.6'

describe 'Test Invoice - Simple' do
	before :all do
		# save the database to restore it later
		dumper.save
		
		login_to_back_office
		set_friendly_urls false
		logout_of_back_office
	end

	after :all do
		# restore the database
		# dumper.load
	end

	before :each do 
		login_to_back_office
		login_to_front_office
	end

	after :each do
		# created cart rules must not outlive a test
		delete_cart_rules
	end

	describe 'Taxes' do
		taxes_tests_root = File.dirname(__FILE__)+'/taxes_tests'
		Dir.entries(taxes_tests_root).each do |entry|
			if entry =~ /\.json$/
				scenario = JSON.parse(File.read("#{taxes_tests_root}/#{entry}"))
				unless scenario['meta']['skip']
					test_name = File.basename(entry, ".json")
					it test_name do
						puts "Running #{entry}"
						test_invoice scenario, :dump_pdf_to => File.dirname(__FILE__)+"/output/taxes_tests/#{test_name}.pdf"
					end
				else
					puts "Skipping #{entry}"
				end
			end
		end
	end

end