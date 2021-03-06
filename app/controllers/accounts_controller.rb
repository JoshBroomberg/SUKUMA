class AccountsController < ApplicationController
	before_action :authenticate_client!
	def show
	if Transaction.where(customer_id: current_client.id).count>0
		@id = params["id"]
		
		@bal = params["bal"].to_f
		@newtrans = Transaction.where("state=3 and customer_id=? and created_at>?", current_client.id, Time.at(params["after"].to_i+1))
		@account = current_client.account
		binding.pry
		@transactions = Transaction.where(customer_id: current_client.id).order(:created_at).reverse
		@tipCategories = TipCategory.all
		@tips = []
		
		@tipCategories.each do |category|
			tipsSample = category.tips.sample(2)
			@tips << tipsSample[0]
			@tips << tipsSample[1]
		end
	else
		redirect_to no_transactions_path
	end
		#binding.pry
	end

	def edit
		@account = current_client.account
		@profile = current_client.profile
		render "editforms"
	end

	def update
		if current_client.account.update(pin_param)
			redirect_to account_path
		else
			@profile = current_client.profile
			render "editforms"
		end
	end

	def welcome
	end



	def pin_param
		params.require(:account).permit(:pin)
	end
end
