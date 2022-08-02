# frozen_string_literal: true

module Deco
  # Creates and returns a hash given the parameters that are used to
  # dynamically create attributes and assign values to a model.
  module AttributeInformable
    module_function

    # This method simply navigates the payload hash received and creates qualified
    # hash key names that can be used to verify/map to our attribute names in this model.
    # This can be used to qualify nested hash attributes and saves us some headaches
    # if there are nested attribute names with the same name:
    #
    # given:
    #
    # hash = {
    #   first_name: 'first_name',
    #   ...
    #   address: {
    #     street: '',
    #     ...
    #   }
    # }
    #
    # attribute_info_from(hash: hash) #=>
    #
    # {
    #   :first_name=>{:attribute_name=>:first_name, :namespace=>[]},
    #   ...
    #   :address_street=>{:attribute_name=>:street, :namespace=>[:address]},
    #   ...
    # }
    #
    # The generated, qualified attribute names expected to map to our model, because we named
    # them as such.
    #
    # :attribute_name is the actual, unqualified attribute name found in the payload hash sent.
    # :namespace is the hash key by which :attribute_name can be found in the payload hash if need be -
    #   retained across recursive calls.
    # :attribute_name_info is a hash to retain the attribute information that will be returned -
    #   retained across recursive calls.
    def attribute_info_from(hash:, namespace: [], attribute_name_info: {})
      hash.each do |key, value|
        if value.is_a? Hash
          attribute_info_from hash: value,
                              namespace: namespace << key,
                              attribute_name_info: attribute_name_info
          namespace.pop
          next
        end

        field_key = [*namespace, key].compact.join('_').to_sym
        attribute_name_info[field_key] = {
          attribute_name: key,
          namespace: namespace.dup
        }
      end

      attribute_name_info
    end
  end
end
