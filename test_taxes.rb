# encoding: UTF-8

require_relative 'lib/bricks.rb'
require_relative 'lib/dumper.rb'

Capybara.app_host = 'http://localhost/1.6'
dumper = Dumper.new :user => 'root', :password => '', :database => '1.6'

describe 'Test Invoice - Simple' do

	free_carrier_name = 'Selenium Free Carrier'

	before :all do
		dumper.save
		#create a free carrier
		login_to_back_office
		create_carrier :name => free_carrier_name,
			:with_handling_fees => false,
			:free_shipping => true
	end

	after :all do
		dumper.load
	end

	describe 'Orders Without Shipping Fees or Reductions' do
		it 'should do stuff' do
			prod_a = create_product :name => 'Petit Sachet de Vis Cruciformes',
				:price => 1.05,
				:tax_group_id => get_or_create_tax_group_id_for_rate(19.6)
			prod_b = create_product :name => 'Gros Sachet de Vis Cruciformes',
				:price => 3.49,
				:tax_group_id => get_or_create_tax_group_id_for_rate(19.6)

			login_to_front_office
			add_products_to_cart [{:id => prod_a, :quantity => 4}]

			order_id = order_current_cart_5_steps :carrier => free_carrier_name

			invoice = validate_order :id => order_id
			invoice['order']['total_products_wt'].to_f.should eq 5.02
		end
	end
end