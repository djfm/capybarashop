# encoding: UTF-8

require_relative 'lib/bricks.rb'
require_relative 'lib/dumper.rb'

# configuration

# READ ME CAREFULLY
# We prefer convention over configuration, so:
# - The shop must have its admin folder named 'admin-dev'
# - The shop must have URL rewriting disabled
# - There must be a superadmin with login pub@prestashop.com/123456789
# - There must be a customer with login pub@prestashop.com/123456789

# Web root of the PrestaShop installation
Capybara.app_host = 'http://localhost/1.6'
# database settings
dumper = Dumper.new :user => 'root', :password => '', :database => '1.6'

describe 'Test Invoice - Simple' do

	it 'should be fun' do
		login_to_back_office
		if false
			create_cart_rule({
				:product_id => 1,
				:name => 'Test Discount',
				:free_shipping => true,
				:amount => 'USD 10 tax excluded'
			})
		end

		create_product({
			:name => 'Lapin Crétin',
			:price => 40,
			:specific_price => '10.2 %'
		})

		sleep 60
	end

end