class MessagesController < ApplicationController
	skip_before_filter  :verify_authenticity_token
	#apply DRY principle
	def create
		
		if params["To"] == "+12316468691"
			vendor = Vendor.where(number: "+12316468691")[0] #chnage to have number from 
			category = "PI" #purchase init
			saveMessage(vendor, category, params["Body"],"+27836538932")
		elsif params["To"] == "+16123612985"
			vendor = Vendor.where(number: "+12316468691")[0] #chnage to have number from
			category = "DI" #deposit init
			saveMessage(vendor, category, params["Body"],"+27836538932")
		elsif params["To"] == "+16123613027"
			user = User.where(number: "+12316468691")[0]
			category = "CONF" #confirm
			saveMessage(user, category, params["Body"], "+27836538932")
		end
		
	end

	def saveMessage(obj, category, body, senderNumber)
		closed = false
		if category !="CONF"
			if body.index(" ") != nil
				parts = body.split(" ")
				if parts[0].length==4
					parts[1] = parts[1].gsub(",", ".")
					if isNumeric parts[1] #validate >0
	
						message = obj.messages.build(account_id: parts[0], amount: parts[1], category: category, closed: closed)

						if message.save
							user = Account.where(account_id: parts[0])[0].accountable
							name = user.firstname
							number = user.number #should go where 083 is
							body = "error..."
							if category == "PI"
								body = "You are making a purchase at <store>, please reply with y/n to confirm number (+16123613027)"
							elsif category == "DI"
								body = "You are making a deposit at <store>, please reply with y/n to confirm number (+16123613027)"
							end
							reply(body, "+27836538932", name)
						end
					else
						reply("Please ensure the amount you entered is a digit and is greater than 0", senderNumber, "Josh")
					end



				else
					reply("AccID must be 4 characters", senderNumber, "Josh")
				end
			else
				reply("Please separate AccID and amount with a space", senderNumber, "Josh")
			end

		else
			if body.length == 1
				if body.index("y") != nil || body.index("n") !=nil
					confirm = nil
					if body=="y"
						confirm = true
					else
						confirm = false
					end
					message = obj.messages.build(category: category, closed: closed, confirm: confirm)
					if message.save
						if confirm
							reply("You have confirmed the requested action", senderNumber, "Josh")

						else
							reply("You have rejected the requested action", senderNumber, "Josh")
						end
					end

				else
					reply("Your message must be either 'y' or 'n'", senderNumber, "Josh")
				end
			else
				reply("Your message must be 1 letter long", senderNumber, "Josh")
			end

		end
	end

	def isNumeric number
		Float(number) != nil rescue false
	end





	def reply(body, number, name)
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
