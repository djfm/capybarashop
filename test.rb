#!/usr/bin/ruby
# encoding: UTF-8

require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'

Capybara.default_driver = :selenium
Capybara.app_host = 'http://localhost/1.6'
Capybara.save_and_open_page_path = "screenshots"

module PrestaShopHelpers
	include Capybara::DSL
	
	def login_to_back_office
		visit '/admin-dev'
		expect(page).to have_selector '#email'
		expect(page).to have_selector '#passwd'
		within '#login_form' do
			fill_in 'email', :with => 'pub@prestashop.com'
			fill_in 'passwd', :with => '123456789'
			check 'stay_logged_in'
			find('button[name=submitLogin]').click
		end
		expect(page).to have_selector '#maintab-AdminDashboard'
	end

	def login_to_front_office
		visit '/'
		find('a.login').click
		within '#login_form' do
			fill_in 'email', :with => 'pub@prestashop.com'
			fill_in 'passwd', :with => '123456789'
			find('#SubmitLogin').click
		end
		page.should_not have_selector '#login_form'
	end

	#preconditions: need to be logged in!
	def create_product options
		find('#maintab-AdminCatalog').hover
		find('#subtab-AdminProducts a').click
		find('#page-header-desc-product-new_product').click
		fill_in 'name_1', :with => options[:name]
		find('#link-Prices').click		
		fill_in 'priceTE', :with => options[:price]
		if options[:tax_group_id]
			within '#id_tax_rules_group' do
				find("option[value='#{options[:tax_group_id]}']").click
			end
		end
		find('#link-Seo').click		
		page.should_not have_field('link_rewrite_1', with: "")
		find('button[name=submitAddproductAndStay]').click
		expect(page).to have_selector '.alert.alert-success'
		return page.current_url[/\bid_product=(\d+)/, 1].to_i
	end

	def create_tax options
		find('#maintab-AdminParentLocalization').hover
		find('#subtab-AdminTaxes a').click
		find('#page-header-desc-tax-new_tax').click
		fill_in 'name_1', :with => options[:name]
		fill_in 'rate', :with => options[:rate]
		find('label[for="active_on"]').click
		find('#tax_form_submit_btn').click
		expect(page).to have_selector '.alert.alert-success'
		return page.current_url[/\bid_tax=(\d+)/, 1].to_i
	end

	def create_tax_group options
		find('#maintab-AdminParentLocalization').hover
		find('#subtab-AdminTaxRulesGroup a').click
		find('#page-header-desc-tax_rules_group-new_tax_rules_group').click
		fill_in 'name', :with => options[:name]
		find('label[for="active_on"]').click
		find('#tax_rules_group_form_submit_btn').click
		expect(page).to have_selector '.alert.alert-success'
		
		options[:taxes].each do |tax|

			behavior = {:no => 0, :sum => 1, :multiply => 2}[tax[:combine] || :no]

			find('#page-header-desc-tax_rule-new').click
			within '#country' do
				find("option[value='#{tax[:country_id] || 0}']").click
			end
			within '#behavior' do
				find("option[value='#{behavior}']").click
			end
			within '#id_tax' do
				find("option[value='#{tax[:tax_id]}']").click
			end

			find('#tax_rule_form_submit_btn').click
			expect(page).to have_selector '.alert.alert-success'
		end

		return page.current_url[/\bid_tax_rules_group=(\d+)/, 1].to_i
	end

	def create_carrier options
		find('#maintab-AdminParentShipping').hover
		find('#subtab-AdminCarriers a').click
		find('#page-header-desc-carrier-new_carrier').click

		fill_in 'name', :with => options[:name]
		fill_in 'delay_1', :with => options[:delay]
		fill_in 'grade', :with => options[:grade] if options[:grade]
		fill_in 'url', :with => options[:tracking_url] if options[:tracking_url]

		find('.buttonNext.btn.btn-default').click

		find("label[for='shipping_handling_#{options[:with_handling_fees] ? 'on' : 'off'}']").click
		find("label[for='is_free_#{options[:free_shipping] ? 'on' : 'off'}']").click

		if options[:based_on] == :price
			choose 'billing_price'
		else
			choose 'billing_weight'
		end

		within '#id_tax_rules_group' do
			find("option[value='#{options[:tax_group_id] || 0}']").click
		end

		oob = options[:out_of_range_behavior] === :highest ? 0 : 1

		within '#range_behavior' do
			find("option[value='#{oob}']").click
		end

		options[:ranges].each_with_index do |range, i|

			if i > 0
				find('#add_new_range').click
			end

			if i == 0
				find("input[name='range_inf[#{i}]']").set range[:from_included]
				find("input[name='range_sup[#{i}]']").set range[:to_excluded]
			else
				find("input[name='range_inf[]']:nth-of-type(#{i})").set range[:from_included]
				find("input[name='range_sup[]']:nth-of-type(#{i})").set range[:to_excluded]
			end

			sleep 1

			range[:prices].each_pair do |zone, price|

				nth = i > 0 ? ":nth-of-type(#{i})" : ""

				if zone == 0
					find('.fees_all input[type="checkbox"]').click if i == 0
					tp = all('.fees_all input[type="text"]')[i]
					tp.set price
					sleep 4
					tp.native.send_keys :tab
				else
					check "zone_#{zone}"
					sleep 1
					if i == 0
						find("input[name='fees[#{zone}][#{i}]']").set price
					else
						find("input[name='fees[#{zone}][]']"+nth).set price
					end
				end
			end
		end

		find('.buttonNext.btn.btn-default').click

		fill_in 'max_height', :with => options[:max_package_height] if options[:max_package_height]
		fill_in 'max_width', :with => options[:max_package_width] if options[:max_package_width]
		fill_in 'max_depth', :with => options[:max_package_depth] if options[:max_package_depth]
		fill_in 'max_weight', :with => options[:max_package_weight] if options[:max_package_weight]

		if !options[:allowed_groups]
			check 'checkme'
		else
			check 'checkme'
			uncheck 'checkme'
			options[:allowed_groups].each do |group|
				check "groupBox_#{group}"
			end
		end

		find('.buttonNext.btn.btn-default').click

		find('label[for="active_on"]').click

		find('a.buttonFinish').click
	end

	def add_products_to_cart products
		products.each do |product|
			visit "/index.php?id_product=#{product[:id]}&controller=product&id_lang=1"
			fill_in 'quantity_wanted', :with => (product[:quantity] || 1)
			find('#add_to_cart button').click
			sleep 1
		end
	end

	def order_current_cart_5_steps
		visit "/index.php?controller=order"
		find('a.standard-checkout').click
		find('button[name="processAddress"]').click
		sleep 2
		expect(page).to have_selector '#cgv'
		check 'cgv'
		find('button[name="processCarrier"]').click
	end
end

RSpec.configure do |config|
  config.include PrestaShopHelpers
end

describe 'Test Invoice' do

	it 'should do stuff' do
		login_to_front_office
		add_products_to_cart [{:id => 3, :quantity => 2}, {:id => 7, :quantity => 4}]
		order_current_cart_5_steps
		sleep 10
	end

	if false
		it 'should work' do
			login_to_back_office

			create_carrier :name => 'Free Carrier',
				:delay => 'Very Slow Like a Turtle',
				:grade => 4,
				:tracking_url => 'http://turtle.com',
				:with_handling_fees => true,
				:free_shipping => false,
				:based_on => :price,
				:tax_group_id => 60,
				:out_of_range_behavior => :highest,
				:ranges => [
					{
						:from_included => 0,
						:to_excluded => 100,
						:prices => {
							0 => 10,
							3 => 4
						}
					},
					{
						:from_included => 110,
						:to_excluded => 200,
						:prices => {
							0 => 5,
							3 => 22
						}
					}
				],
			:max_package_height => 22,
			:max_package_width => 43,
			:max_package_depth => 43,
			:max_package_weight => 43,
			:allowed_groups => [1, 3]

			if false
				tax_id = create_tax :name => 'Ancienne TVA Française', :rate => 19.6
				tax_group_id = create_tax_group :name => 'FRRRR', :taxes => [{:tax_id => tax_id}]

				product0 = create_product :name => 'Petit Sachet de Vis Cruciformes', :price => 1.05, :tax_group_id => tax_group_id
				product1 = create_product :name => 'Gros Sachet de Vis Cruciformes', :price => 3.49, :tax_group_id => tax_group_id
			end
		end
	end
end