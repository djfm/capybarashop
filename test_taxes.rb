# encoding: UTF-8

require_relative 'lib/bricks.rb'

Capybara.app_host = 'http://localhost/1.6'

describe 'Test Invoice - Simple' do

	free_carrier_name = 'Selenium Free Carrier'

	taxes_needed = [19.6]
	tax_groups = {}

	before :all do
		puts "Dumping DB before run of tests..."
		puts `mysqldump -uroot 1.6 > dumps/db.sql`

		#create a free carrier
		login_to_back_office
		create_carrier :name => free_carrier_name,
			:with_handling_fees => false,
			:free_shipping => true

		taxes_needed.each do |rate|
			tax_id = create_tax :name => "#{rate}% Tax (Rate)", :rate => rate
			tax_group_id = create_tax_group :name => "#{rate}% Tax (Group)",
				:taxes => [{:tax_id => tax_id}]
			tax_groups[rate] = tax_group_id
		end
	end

	after :all do
		puts "Restoring the DB after run of tests..."
		puts `mysql -uroot 1.6 < dumps/db.sql`
	end

	describe 'Orders Without Shipping Fees or Reductions' do
		it 'should do stuff' do
			prod_a = create_product :name => 'Petit Sachet de Vis Cruciformes',
				:price => 1.05,
				:tax_group_id => tax_groups[19.6]
			prod_b = create_product :name => 'Gros Sachet de Vis Cruciformes',
				:price => 3.49,
				:tax_group_id => tax_groups[19.6]

			login_to_front_office
			add_products_to_cart [{:id => prod_a, :quantity => 4}]

			order_id = order_current_cart_5_steps :carrier => free_carrier_name

			invoice = validate_order :id => order_id
			invoice['order']['total_products_wt'].to_f.should eq 5.02
		end
	end
end