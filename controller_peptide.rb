def get_create_peptide(peptide_sequence)
    peptide_object = Peptide.first_or_create(:sequence => peptide_sequence)
    puts peptide_object.sequence
    if peptide_object.save
        puts "SAVED"
    end
    return peptide_object
end

def get_create_dataset(dataset_name)
    dataset_object = Dataset.first_or_create(:name => dataset_name)
    dataset_object.save
    return dataset_object
end

def create_dataset_peptide_link(peptide_sequence_db, dataset_name_db)
    join_object = DatasetPeptide.first_or_create(:peptide => peptide_sequence_db, :dataset => dataset_name_db)
    join_object.save
    return join_object
end