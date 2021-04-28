class CreditCardUtils

	def self.expiration_date_validated?(expiration_date)
		return if expiration_date.blank? || expiration_date.class != String
		regex = /^(0[1-9]|1[0-2])\/([0-9]{2})$/
		expiration_date.match(regex).present?
	end

end