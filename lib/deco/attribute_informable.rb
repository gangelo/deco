# frozen_string_literal: true

module Deco
  # Creates and returns a hash given the parameters that are used to
  # dynamically create attributes and assign values to a model.
  module AttributeInformable
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
    #   :first_name=>{:attribute_name=>:first_name, :in=>[]},
    #   ...
    #   :address_street=>{:attribute_name=>:street, :in=>[:address]},
    #   ...
    # }
    #
    # The generated, qualified attribute names expected to map to our model, because we named
    # them as such.
    #
    # :attribute_name is the actual, unqualified attribute name found in the payload hash sent.
    # :in is the hash key by which :attribute_name can be found in the payload hash if need be.
    def attribute_info_from(hash:, namespace: [], attribute_name_info: {})
      hash.each do |key, value|
        if value.is_a? Hash
          namespace << key
          attribute_info_from hash: value, namespace: namespace,
                              attribute_name_info: attribute_name_info
          namespace.pop
          next
        end

        namespace = namespace.dup
        if namespace.blank?
          attribute_name_info[key] = { attribute_name: key, in: namespace }
        else
          attribute_name_info["#{namespace.join('_')}_#{key}".to_sym] =
            { attribute_name: key, in: namespace }
        end
      end

      attribute_name_info
    end
  end
end
