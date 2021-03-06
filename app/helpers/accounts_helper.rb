module AccountsHelper

	def spendData

		percentagehash = {}
		transactions = Transaction.where(:created_at => 1.months.ago..Time.now, customer_id: current_client.id, state: 3, kind: 0)
		deposits = Transaction.where(:created_at => 1.months.ago..Time.now, customer_id: current_client.id, state: 3, kind: 1)
		
		sum = 0.0
		p2psum = 0.0
		prefixSum = {}
		counter = 1
		transactions.each do |transaction|
			if Client.find(transaction.vendor_id).profile.class.name == "Cprofile"
				p2psum += transaction.amount
			end
			sum+=transaction.amount
			if prefixSum.length>0
				prefixSum[counter] = (prefixSum[counter-1]+transaction.amount)
			else
				prefixSum[counter]=(transaction.amount)
			end
			counter+=1
		end

		totalSpend = prefixSum[prefixSum.keys.max]
		average = totalSpend/prefixSum.count
		


		



		#binding.pry

		prefixSumD = {}
		counterD = 1
		deposits.each do |deposit|
			if prefixSumD.length>0
				prefixSumD[counterD] = (prefixSumD[counterD-1]+deposit.amount)
			else
				prefixSumD[counterD]=(deposit.amount)
			end
			counterD+=1
		end

		totalDeposits = prefixSumD[prefixSumD.keys.max]
		averageD = totalDeposits/prefixSumD.count

		predictedBalance = {}
		zeroHash = {}
		balance = current_client.account.balance
		(0..30).each do |day|
			balance = balance-average+averageD
			predictedBalance[day] = balance
			zeroHash[day.to_s] = 0
		end

		Profile.categories.each do |key, value|
			# catTrans = []
			# transactions.each do |trans|

			# 	if Client.find(trans.vendor_id).profile.category == key	
			# 		catTrans<<trans			
			# 	end
			# end
			catTrans = transactions.select{|transaction| Client.find(transaction.vendor_id).profile.category == key	}
			catTrans = catTrans.reject{|trans| Client.find(trans.vendor_id).profile.class.name == "Cprofile"}
			subSum = 0.0
			catTrans.each do |trans|
				subSum+= trans.amount
			end
			percentagehash[key] = subSum

		end
		

		percentagehash.each do |key,value|
			percentagehash[key] = (value/(sum-p2psum)*100).round(2)
		end
		percentagehash["Transfers"] = p2psum/(sum)*100.round(2)


		#ages = { "Bruce" => 32, "Clark" => 28 }
		#mappings = {"Bruce" => "Bruce Wayne", "Clark" => "Clark Kent"1
		mappings ={}
		cnt = 1
		prefixSum.each do 
			mappings[cnt] =  "Transaction "+cnt.to_s
			cnt+=1
		end
		prefixSum.keys.each { |k| prefixSum[ mappings[k] ] = prefixSum.delete(k) if mappings[k] }
		
		# prefixSum2 = {}
		# prefixSum.each do |key, value|
		# 	prefixSum2[key] = current_client.account.balance
		# end

		mappings ={}
		cnt = 1
		prefixSumD.each do 
			mappings[cnt] =  "Transaction "+cnt.to_s
			cnt+=1
		end
		prefixSumD.keys.each { |k| prefixSumD[ mappings[k] ] = prefixSumD.delete(k) if mappings[k] }

		
		mappings ={}
		cnt = 0
		predictedBalance.each do 
			mappings[cnt] =  cnt.to_s
			cnt+=1
		end
		predictedBalance.keys.each { |k| predictedBalance[ mappings[k] ] = predictedBalance.delete(k) if mappings[k] }
		
		if prefixSum.count>prefixSumD.count
		val = 0.0
		prefixSum.each do |key, value|
			if !prefixSumD.include?(key)
			   prefixSumD[key] = val
			else
				val = prefixSumD[key]
			end
		end
		else
			val = 0.0
		prefixSumD.each do |key, value|
			if !prefixSum.include?(key)
			   prefixSum[key] = val
			else
				val = prefixSum[key]
			end
		end


		end



		# transactions = transactions.group_by_day(:created_at).count

		# mappings ={}
		# oldkeys = transactions.keys
		# cnt = 0
		# transactions.each do 
		# 	mappings[oldkeys[cnt]] =  oldkeys[cnt].to_s[0...10]
		# 	cnt+=1
		# end

		# transactions.keys.each { |k| transactions[ mappings[k] ] = transactions.delete(k) if mappings[k] }

		transactions = transactions.group("date(created_at)").select("date(created_at)", "sum(amount)")
		transactionsHash  = {}
        transactions.each do |transaction|
        	transactionsHash[transaction.date] = transaction.sum
        end

        deposits = deposits.group("date(created_at)").select("date(created_at)", "sum(amount)")
		depositsHash  = {}
        deposits.each do |deposit|
        	depositsHash[deposit.date] = deposit.sum
        end
        
		
		# deposits = deposits.group_by_day(:created_at).count
		# mappings ={}
		# oldkeys = deposits.keys
		# cnt = 0
		# deposits.each do 
		# 	mappings[oldkeys[cnt]] =  oldkeys[cnt].to_s[0...10]
		# 	cnt+=1
		# end
		# deposits.keys.each { |k| deposits[ mappings[k] ] = deposits.delete(k) if mappings[k] }

		

		idealPercents = {"Food" => 15,  "Transport"=> 20,"Clothing"=> 10, "Housing"=> 25, "Medical"=> 5,"Recreation"=> 20, "Other"=> 5}

		[percentagehash, prefixSum, prefixSumD, transactionsHash, depositsHash, idealPercents, predictedBalance, zeroHash]
		
	end

	def futureData

	

	end	


end
