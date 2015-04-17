

def get_create_modification(modification_string)
	return Modification.first_or_create(:name => modification_string)
end