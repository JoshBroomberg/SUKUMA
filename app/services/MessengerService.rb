class MessengerService

	def saveMessage(kind, body, senderNumber, name)
		user = Client.find_by(number: senderNumber)
		closed = false
		if kind != :confirm
			if body.index(" ") != nil
				parts = body.split(" ")
				if parts[0].length==4
					parts[0] = parts[0].downcase
					parts[1] = parts[1].gsub(",", ".")
					if isNumeric parts[1] #validate >0
						message = user.messages.build(account_id: parts[0], amount: parts[1], kind: kind)
						if message.save
							clientAcc = Account.find_by(account_id: parts[0])
							client = clientAcc.client
							clientname = client.profile.firstname
							number = "+27836538932" #client.number #should go where 083 is
							body = "error..."
							if kind == :purchaseInit
								body = "You are making a purchase at #{user.profile.businessname}, value R#{parts[1]}. Please sendMessage with y/n to confirm number (+16123613027)"
								kind = :purchase
							elsif kind == :depositInit
								body = "You are making a deposit at #{user.profile.businessname}, value R#{parts[1]}. Please sendMessage with y/n to confirm number (+16123613027)"
								kind = :deposit
							end
							
							#create a transaction
							ts = TransactionService.new()
							ts.processTranaction(client, user, message.amount, kind, body)

						end
					else
						sendMessage("Please ensure the amount you entered is a digit and is greater than 0", senderNumber, name)
					end



				else
					sendMessage("AccID must be 4 characters", senderNumber, name)
				end
			else
				sendMessage("Please separate AccID and amount with a space", senderNumber, name)
			end

		else
			#user = User.where(number: params["From"])[0]
			useraccount = user.account
			transaction  = Transaction.find_by(customer_id: user.id, state: 1)
			#binding.pry
			if Transaction.where(customer_id: user.id, state: 1).count > 0
				vendor = Client.find(transaction.vendor_id)
			    vendoraccount = vendor.account
				
				if body.length == 1
					if body.index("y") != nil || body.index("n") !=nil

						confirm = nil
						if body=="y"
							confirm = true
						else
							confirm = false
						end
						message = user.messages.build(kind: kind, confirm: confirm)
						if message.save
							if confirm
								
								#update account
								ubalance = useraccount.balance
								vbalance = vendoraccount.balance
								if transaction.kind == "purchase"
									ubalance = ubalance-transaction.amount
									vbalance = vbalance+transaction.amount
									
								elsif transaction.kind == "deposit"
									ubalance = ubalance+transaction.amount
									vbalance = vbalance-transaction.amount
									
								end
								

								if useraccount.update(balance: ubalance) && vendoraccount.update(balance: vbalance)
									transaction.update(state: :success)
									sendMessage("You have confirmed the requested action, your current balance is R#{ubalance}", senderNumber, name)
									#send confirm message to vendor here
									#sendMessage("You have confirmed the requested action, your current balance is #{balance}", senderNumber, name)
								end
								

							else
								transaction.update(state: :reject)
								sendMessage("You have rejected the requested action", senderNumber, name)
								#send reject message to vendor here
								#sendMessage("You have confirmed the requested action, your current balance is #{balance}", senderNumber, name)
							end
						end

					else
						sendMessage("Your message must be either 'y' or 'n'", senderNumber, name)
					end
				else
					sendMessage("Your message must be 1 letter long", senderNumber, name)
				end
			else
				sendMessage("You have no transactions to confirm", senderNumber, name)
			end
		end
	end

	def isNumeric number
		Float(number) != nil rescue false
	end

	def sendMessage(body, number, name)
		account_sid = "ACabc2a633d8052c4b8805de4b678f4166"
		auth_token = "255b0b0cd465bbd6d0e3b3a32cd1ad4e"
		client = Twilio::REST::Client.new account_sid, auth_token

		from = "+12316468691"

		friends = {
			number => name
		}
		friends.each do |key, value|
			client.account.messages.create(
				:from => from,
				:to => key,
				:body => "Hi #{name}... "+body
				)
			
		end
	end
end