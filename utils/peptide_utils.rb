

def get_create_psm(variant_db, dataset_db, protein_db, peptide_db, tab_file, scan_number, filename, sequence)   
    psm = Peptidespectrummatch.first_or_create(
        :filename => filename, 
        :scan => scan_number, 
        :tabfile => tab_file, 
        :sequence => sequence,
        :variant => variant_db,
        :dataset => dataset_db,
        :peptide => peptide_db, 
        :protein => protein_db)
    

    return psm
end


def get_create_peptide(peptide_sequence, dataset_db, protein_db)
    stripped_sequence = peptide_sequence.gsub(/\W+/, '').gsub(/\d\s?/, '')    
    peptide_db = Peptide.first_or_create(:sequence => stripped_sequence)
    variant_db = Variant.first_or_create(:sequence => peptide_sequence, :peptide => peptide_db)

    DatasetPeptide.first_or_create(:dataset => dataset_db, :peptide => peptide_db, :sequence => stripped_sequence)
    PeptideProtein.first_or_create(:protein => protein_db, :peptide => peptide_db, :sequence => stripped_sequence)

    return peptide_db, variant_db
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
