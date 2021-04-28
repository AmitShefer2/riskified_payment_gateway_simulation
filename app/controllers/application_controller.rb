class ApplicationController < ActionController::API

  	before_action :validate_merchant_identifier

	def validate_merchant_identifier
		merchant_identifier = request.headers['merchant-identifier']
		if merchant_identifier.blank? || merchant_identifier.class != String
			render body: nil, status: 400
		end
	end

end
