class TransactionsController < ApplicationController
	before_action :authenticate_client!
	def index
		@transactions = Transaction.where(customer_id: current_client.id)
	end

	def new
		@transaction = Transaction.new
	end

	def create
		require "TransactionService"
		ts = TransactionService.new()
		vendorAcc = Account.find_by(account_id: params[:accID])
		vendor = vendorAcc.client
		ts.processTranaction(current_client, vendor, trans_params[:amount], :purchaseInit)
	end

	def trans_params
		params.require(:transaction).permit(:amount, :accID)
	end
end
