

def get_create_psm(peptide_db, dataset_db, join_dataset_peptide, tab_file, scan_number, filename)
    #join_dataset_peptide = DatasetPeptide.first(:dataset => dataset_db, :peptide => peptide_db)    
    psm = Datasetpeptidespectrummatch.create(:filename => filename, :scan => scan_number, :tabfile => tab_file, :DatasetPeptide => join_dataset_peptide)

end


def get_create_peptide(peptide_sequence, modifications)
    stripped_sequence = peptide_sequence.gsub(/\W+/, '').gsub(/\d\s?/, '')    
    peptide_object = Peptide.first_or_create(:sequence => stripped_sequence)
    peptide_object.save
    variant_object = Variant.first_or_create(:sequence => peptide_sequence, :peptide => peptide_object)

    #Adding Modifications
    modifications.each { |modification|
        modification_split = modification.split("-")
        mod_name = modification_split[1]
        mod_location = modification_split[0]
        modification_db = Modification.first_or_create(:name => mod_name)

        #Creating connection
        mod_variant_db = ModificationVariant.first_or_create(:modification => modification_db, :variant => variant_object, :location => mod_location)
    }

    return peptide_object, variant_object
end

def get_create_dataset(dataset_name)
    dataset_object = Dataset.first_or_create(:name => dataset_name)
    dataset_object.save
    return dataset_object
end

def create_dataset_peptide_link(peptide_sequence_db, basicpeptide_db, dataset_name_db)
    BasicpeptideDataset.first_or_create(:basicpeptide => basicpeptide_db, :dataset => dataset_name_db)
    join_object = DatasetPeptide.first_or_create(:peptide => peptide_sequence_db, :dataset => dataset_name_db)
    join_object.save
    return join_object
end
