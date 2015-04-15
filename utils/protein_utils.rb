
def get_create_protein(protein_name)
    protein_object = Protein.first_or_create(:name => protein_name)
    
    if protein_object.save
        #puts "SAVED"
    end
    return protein_object
end

def create_dataset_protein_link(protein_db, dataset_db)
    join_object = DatasetProtein.first_or_create(:protein => protein_db, :dataset => dataset_db)
    join_object.save
    return join_object
end