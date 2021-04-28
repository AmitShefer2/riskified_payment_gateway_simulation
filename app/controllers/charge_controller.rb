class ChargeController < ApplicationController

	INTEGRATED_CREDIT_CARD_COMPANIES = ['visa', 'mastercard']

	def create
		if credit_card_info_validated?
			perform_charge
			return
		end
		render_client_error
	end

	private

	def perform_charge
		credit_card_company = permitted_params[:creditCardCompany]
		response = ChargeManager.new(credit_card_company, permitted_params).charge
		method("handle_#{credit_card_company}_response").call(response)
	end

	def handle_visa_response(response)
		if response.code == 200
			response_body = JSON.parse(response.body)
			return render_business_error if response_body['chargeResult'] == 'Failure'
			return render_success
		end
		render_technical_error
	end

	def handle_mastercard_response(response)
		return render_success if response.code == 200
		return render_business_error if response.code == 400
		render_technical_error
	end

	def permitted_params
		params.permit(:fullName, :creditCardNumber, :creditCardCompany, :expirationDate, :cvv, :amount)
	end

	def credit_card_info_validated?
		return if !string_param_validated?(permitted_params[:fullName])
		return if !string_param_validated?(permitted_params[:creditCardNumber])
		return if !string_param_validated?(permitted_params[:cvv])
		return if permitted_params[:amount].blank? || !is_decimal?(permitted_params[:amount])
		return if !INTEGRATED_CREDIT_CARD_COMPANIES.include?(params[:creditCardCompany])
		return if !CreditCardUtils.expiration_date_validated?(permitted_params[:expirationDate])
		true
	end

	def string_param_validated?(param)
		param.present? && param.class == String
	end

	def is_decimal?(value)
		value % 1 != 0
	end

	def render_business_error
		render json: { error: 'Card declined' }, status: 200
	end

	def render_success
		render body: nil, status: 200
	end

	def render_client_error
		render body: nil, status: 400
	end

	def render_technical_error
		render body: nil, status: 500
	end

end