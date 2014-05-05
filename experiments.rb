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
		login_to_front_office
		add_products_to_cart [{id: 1, quantity: 1}]
		order_current_cart_opc :carrier => 'My carrier'
		sleep 60
	end

end