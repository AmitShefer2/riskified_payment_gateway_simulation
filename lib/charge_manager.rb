class ChargeManager

	COMMUNICATION_ATTEMPT_LIMIT = 3
  	MOCK_SERVER_URL = 'https://interview.riskxint.com'.freeze

  	def initialize(card_company, client_params)
  		@card_company = card_company
  		@client_params = client_params
  	end

	def charge
		communication_attempt_count = 0
		request_params = method("#{@card_company}_request_params").call()
		begin
			RestClient::Request.execute({
				method: :post,
				url: request_params[:url],
				payload: request_params[:payload],
				headers: {
					identifier: 'Amit'
				}
			})
		rescue RestClient::ExceptionWithResponse => error
			error_response = error.response
			return error_response if is_business_error?(error)
			return error_response if communication_attempt_count >= COMMUNICATION_ATTEMPT_LIMIT
			communication_attempt_count += 1
			sleep communication_attempt_count ** 2
			retry
		end
	end

  	private

	def is_business_error?(error)
		return true if @card_company == 'mastercard' && error.response.code == 400
	end

	def visa_request_params
		{
			url: "#{MOCK_SERVER_URL}/visa/api/chargeCard",
			payload: {
				fullName: @client_params[:fullName],
				number: @client_params[:creditCardNumber],
				expiration: @client_params[:expirationDate],
				cvv: @client_params[:cvv],
				totalAmount: @client_params[:amount]
			}
		}
	end

	def mastercard_request_params
		splitted_full_name = @client_params[:fullName].split(' ')
		{
			url: "#{MOCK_SERVER_URL}/mastercard/capture_card",
			payload: {
				first_name: splitted_full_name[0],
				last_name: splitted_full_name[1],
				card_number: @client_params[:creditCardNumber],
				expiration: @client_params[:expirationDate].sub!('/', '-'),
				cvv: @client_params[:cvv],
				charge_amount: @client_params[:amount]
			}
		}
	end

end