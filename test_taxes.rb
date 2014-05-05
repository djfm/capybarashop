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
	before :all do
		dumper.save
	end

	after :all do
		dumper.load
	end

	before :each do 
		login_to_back_office
		login_to_front_office
	end

	describe 'Basic Orders' do

		it 'Should work with 2 products and no shipping' do
			test_invoice({
				meta: {
					order_process: :five_steps,
					rounding_rule: :total,
					rounding_method: :half_up 
				},
				carrier: {
					name: 'SeleniumShipping',
					with_handling_fees: false,
					shipping_fees: 0
				},
				products: {
					'Petit Sachet de Vis Cruciformes' => {
						price: 1.05,
						vat: 19.6,
						quantity: 1
					},
					'Gros Sachet de Vis Cruciformes' => {
						price: 3.49,
						vat: 19.6,
						quantity: 2
					}
				},
				expect: {
					invoice: {
						total: {
							total_with_tax: 9.61
						}
					}
				}
			})
		end

		it 'Should work with one product and no shipping' do
			test_invoice({
				meta: {
					order_process: :opc,
					rounding_rule: :total,
					rounding_method: :half_up 
				},
				carrier: {
					name: 'SeleniumShipping',
					with_handling_fees: false,
					shipping_fees: 0
				},
				products: {
					'Petit Sachet de Vis Cruciformes' => {
						price: 1.05,
						vat: 19.6,
						quantity: 4
					}
				},
				expect: {
					invoice: {
						total: {
							total_with_tax: 5.02
						}
					}
				}
			})
		end

	end

end