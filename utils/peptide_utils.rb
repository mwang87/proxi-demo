

def get_create_psm(variant_db, dataset_db, join_dataset_variant, protein_dataset_join, tab_file, scan_number, filename)   
    psm = Datasetvariantspectrummatch.create(
        :filename => filename, 
        :scan => scan_number, 
        :tabfile => tab_file, 
        :DatasetVariant => join_dataset_variant,
        :DatasetProtein => protein_dataset_join)

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
        mod_peptide_db = ModificationPeptide.first_or_create(:modification => modification_db, :peptide => peptide_object)
        #puts mod_name + "\t" + peptide_sequence
    }

    return peptide_object, variant_object
end

def get_create_dataset(dataset_name)
    dataset_object = Dataset.first_or_create(:name => dataset_name)
    dataset_object.save
    return dataset_object
end

def create_dataset_peptide_link(variant_db, peptide_db, dataset_db)
    datset_peptide_db = DatasetPeptide.first_or_create(:peptide => peptide_db, :dataset => dataset_db)
    dataset_variant_db = DatasetVariant.first_or_create(:variant => variant_db, :dataset => dataset_db)
    return datset_peptide_db, dataset_variant_db
end
