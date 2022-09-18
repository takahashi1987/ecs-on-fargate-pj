require 'rails_helper'

RSpec.describe "Example", type: :request do

	describe 'GET /example' do
		subject(:result) { get example_path }

		it 'accessible' do
			expect(result).to eq 200
		end
	end
end
