
#List all the basic peptides
get '/peptide/list' do
    #@all_peptides = Basicpeptide.all
    page_number = 1
    if params[:page] != nil
        page_number = params[:page].to_i
    end

    #Determining next and prev page
    if page_number == 1
        @next_page = page_number + 1
        @previous_page = nil
    else
        @next_page = page_number + 1
        @previous_page = page_number - 1
    end


    @all_peptides = Basicpeptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
    haml :peptide_all
end

#List all the variants of a given peptide
get '/peptide/:peptide/variant/list' do
    page_number = 1
    if params[:page] != nil
        page_number = params[:page].to_i
    end

    #Determining next and prev page
    if page_number == 1
        @next_page = page_number + 1
        @previous_page = nil
    else
        @next_page = page_number + 1
        @previous_page = page_number - 1
    end

    basic_peptide = Basicpeptide.first(:sequence => params[:peptide])
    @variants = basic_peptide.peptides(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :variant_all
end

#List all the basic peptides in a dataset
get '/peptide/:peptide/dataset/list' do
    query_peptide = params[:peptide]
    peptide_object = Basicpeptide.first(:sequence => query_peptide)
    
    if peptide_object == nil
        return "{}"
    end
    
    @datasets = peptide_object.datasets
    @peptide = query_peptide
    haml :peptide_datasets
end

#For each basic peptide, and dataset, list all the variants
get '/peptide/:peptide/dataset/:dataset/variants/list' do
    peptide_db = Basicpeptide.first(:sequence => params[:peptide])
    dataset_db = Dataset.first(:name => params[:dataset])
    
    join_dataset_peptide = BasicpeptideDataset.first(:dataset => dataset_db, :basicpeptide => peptide_db)
    
    #psms = Datasetpeptidespectrummatch.all(:DatasetPeptide => join_dataset_peptide)

    #psms.to_json()
end



def get_create_psm(peptide_db, dataset_db, join_dataset_peptide, tab_file, scan_number, filename)
    #join_dataset_peptide = DatasetPeptide.first(:dataset => dataset_db, :peptide => peptide_db)    
    psm = Datasetpeptidespectrummatch.create(:filename => filename, :scan => scan_number, :tabfile => tab_file, :DatasetPeptide => join_dataset_peptide)

end


def get_create_peptide(peptide_sequence)
    peptide_object = Peptide.first_or_create(:sequence => peptide_sequence)
    
    #stripping out PTMs from peptide object
    stripped_sequence = peptide_sequence.gsub(/\W+/, '').gsub(/\d\s?/, '')
    #puts peptide_sequence
    #puts "STRIPPED: " + stripped_sequence
    basic_peptide_object = Basicpeptide.first_or_create(:sequence => stripped_sequence)
    basic_peptide_object.save
    
    peptide_object.basicpeptide = basic_peptide_object
    #puts peptide_object.sequence
    if peptide_object.save
        #puts "SAVED"
    end
    return peptide_object, basic_peptide_object
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

